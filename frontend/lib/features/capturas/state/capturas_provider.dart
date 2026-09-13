import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../../levantamientos/state/levantamientos_provider.dart';
import '../data/capturas_repository.dart';
import '../models/captura.dart';

final capturasRepositoryProvider = Provider<CapturasRepository>((ref) {
  return CapturasRepository(ref.watch(apiDioProvider));
});

final capturasProvider =
    AsyncNotifierProvider.family<CapturasNotifier, List<Captura>, String>(
  (levantamientoId) => CapturasNotifier(levantamientoId),
);

class CapturasNotifier extends AsyncNotifier<List<Captura>> {
  CapturasNotifier(this.levantamientoId);

  final String levantamientoId;

  @override
  Future<List<Captura>> build() {
    return ref.read(capturasRepositoryProvider).findByLevantamiento(levantamientoId);
  }

  Future<void> refresh() async {
    // Sin pasar por AsyncLoading: así la grilla no desaparece (ni se pierde
    // el scroll) cada vez que se sube una captura.
    state = await AsyncValue.guard(
      () => ref.read(capturasRepositoryProvider).findByLevantamiento(levantamientoId),
    );
  }

  Future<void> subir({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    String? notas,
    double? latitud,
    double? longitud,
  }) async {
    await ref.read(capturasRepositoryProvider).upload(
          levantamientoId: levantamientoId,
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
          notas: notas,
          latitud: latitud,
          longitud: longitud,
        );
    await refresh();
    ref.invalidate(levantamientosProvider);
  }

  Future<void> eliminar(String capturaId) async {
    await ref.read(capturasRepositoryProvider).remove(capturaId);
    await refresh();
  }
}
