import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../data/checklist_plantillas_repository.dart';
import '../models/checklist_plantilla.dart';
import '../models/plantilla_seccion.dart';

final checklistPlantillasRepositoryProvider = Provider<ChecklistPlantillasRepository>((ref) {
  return ChecklistPlantillasRepository(ref.watch(apiDioProvider));
});

final checklistPlantillasProvider =
    AsyncNotifierProvider<ChecklistPlantillasNotifier, List<ChecklistPlantilla>>(
  ChecklistPlantillasNotifier.new,
);

class ChecklistPlantillasNotifier extends AsyncNotifier<List<ChecklistPlantilla>> {
  @override
  Future<List<ChecklistPlantilla>> build() {
    return ref.read(checklistPlantillasRepositoryProvider).findAll();
  }

  Future<void> refresh() async {
    // Sin pasar por AsyncLoading para no perder el scroll de la lista.
    state = await AsyncValue.guard(() => ref.read(checklistPlantillasRepositoryProvider).findAll());
  }

  Future<ChecklistPlantilla> crear({required String nombre, String? descripcion, String? duplicarDeId}) async {
    final creada = await ref.read(checklistPlantillasRepositoryProvider).create(
          nombre: nombre,
          descripcion: descripcion,
          duplicarDeId: duplicarDeId,
        );
    await refresh();
    return creada;
  }

  Future<void> eliminar(String id) async {
    await ref.read(checklistPlantillasRepositoryProvider).remove(id);
    await refresh();
  }
}

final checklistPlantillaDetalleProvider =
    AsyncNotifierProvider.family<ChecklistPlantillaDetalleNotifier, ChecklistPlantilla, String>(
  (id) => ChecklistPlantillaDetalleNotifier(id),
);

class ChecklistPlantillaDetalleNotifier extends AsyncNotifier<ChecklistPlantilla> {
  ChecklistPlantillaDetalleNotifier(this.plantillaId);

  final String plantillaId;

  @override
  Future<ChecklistPlantilla> build() {
    return ref.read(checklistPlantillasRepositoryProvider).findOne(plantillaId);
  }

  Future<void> refresh() async {
    // Sin pasar por AsyncLoading: el builder mantiene la estructura visible
    // (con su scroll) mientras se recarga tras guardar/subir un logo.
    state = await AsyncValue.guard(() => ref.read(checklistPlantillasRepositoryProvider).findOne(plantillaId));
  }

  Future<void> actualizarMetadata({String? nombre, String? descripcion}) async {
    await ref
        .read(checklistPlantillasRepositoryProvider)
        .update(plantillaId, nombre: nombre, descripcion: descripcion);
    await refresh();
  }

  Future<void> guardarEstructura(List<PlantillaSeccion> secciones) async {
    await ref.read(checklistPlantillasRepositoryProvider).reemplazarEstructura(plantillaId, secciones);
    await refresh();
  }

  Future<void> subirLogo(String tipo, List<int> bytes, String fileName) async {
    await ref.read(checklistPlantillasRepositoryProvider).subirLogo(plantillaId, tipo, bytes, fileName);
    await refresh();
  }
}
