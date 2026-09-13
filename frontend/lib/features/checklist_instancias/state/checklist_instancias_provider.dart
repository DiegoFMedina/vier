import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../data/checklist_instancias_repository.dart';
import '../models/checklist_instancia.dart';

final checklistInstanciasRepositoryProvider = Provider<ChecklistInstanciasRepository>((ref) {
  return ChecklistInstanciasRepository(ref.watch(apiDioProvider));
});

final checklistInstanciasPorLevantamientoProvider = AsyncNotifierProvider.family<
    ChecklistInstanciasPorLevantamientoNotifier, List<ChecklistInstanciaResumen>, String>(
  (levantamientoId) => ChecklistInstanciasPorLevantamientoNotifier(levantamientoId),
);

class ChecklistInstanciasPorLevantamientoNotifier
    extends AsyncNotifier<List<ChecklistInstanciaResumen>> {
  ChecklistInstanciasPorLevantamientoNotifier(this.levantamientoId);

  final String levantamientoId;

  @override
  Future<List<ChecklistInstanciaResumen>> build() {
    return ref.read(checklistInstanciasRepositoryProvider).findByLevantamiento(levantamientoId);
  }

  Future<void> refresh() async {
    // No se limpia el estado a AsyncLoading antes de recargar: eso haría
    // desaparecer la lista (y perder el scroll) mientras llega la respuesta.
    // Se mantienen los datos previos visibles hasta tener los nuevos.
    state = await AsyncValue.guard(
      () => ref.read(checklistInstanciasRepositoryProvider).findByLevantamiento(levantamientoId),
    );
  }

  Future<ChecklistInstancia> crear(String plantillaId) async {
    final creada = await ref.read(checklistInstanciasRepositoryProvider).create(levantamientoId, plantillaId);
    await refresh();
    return creada;
  }

  Future<void> eliminar(String id) async {
    await ref.read(checklistInstanciasRepositoryProvider).remove(id);
    await refresh();
  }
}

final checklistInstanciaDetalleProvider =
    AsyncNotifierProvider.family<ChecklistInstanciaDetalleNotifier, ChecklistInstancia, String>(
  (id) => ChecklistInstanciaDetalleNotifier(id),
);

class ChecklistInstanciaDetalleNotifier extends AsyncNotifier<ChecklistInstancia> {
  ChecklistInstanciaDetalleNotifier(this.instanciaId);

  final String instanciaId;

  @override
  Future<ChecklistInstancia> build() {
    return ref.read(checklistInstanciasRepositoryProvider).findOne(instanciaId);
  }

  Future<void> refresh() async {
    // Igual que en el notifier de arriba: no se pasa por AsyncLoading para no
    // reemplazar el formulario/lista de ítems por un spinner (y perder el
    // scroll) cada vez que se responde un ítem.
    state = await AsyncValue.guard(() => ref.read(checklistInstanciasRepositoryProvider).findOne(instanciaId));
  }

  Future<void> actualizarMetadata(Map<String, dynamic> data) async {
    await ref.read(checklistInstanciasRepositoryProvider).update(instanciaId, data);
    await refresh();
  }

  Future<void> responderItem(String itemId, {String? valor, String? observaciones}) async {
    await ref.read(checklistInstanciasRepositoryProvider).responderItem(
          instanciaId,
          itemId,
          valor: valor,
          observaciones: observaciones,
        );
    await refresh();
  }

  Future<void> agregarRevision(Map<String, dynamic> data) async {
    await ref.read(checklistInstanciasRepositoryProvider).agregarRevision(instanciaId, data);
    await refresh();
  }

  Future<void> subirLogo(String tipo, List<int> bytes, String fileName) async {
    await ref.read(checklistInstanciasRepositoryProvider).subirLogo(instanciaId, tipo, bytes, fileName);
    await refresh();
  }
}
