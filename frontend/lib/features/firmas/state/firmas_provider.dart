import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../../checklist_instancias/models/instancia_firma.dart';
import '../data/firmas_repository.dart';
import '../models/firma_guardada.dart';

final firmasRepositoryProvider = Provider<FirmasRepository>((ref) {
  return FirmasRepository(ref.watch(apiDioProvider));
});

final firmasGuardadasProvider =
    AsyncNotifierProvider<FirmasGuardadasNotifier, List<FirmaGuardada>>(
  FirmasGuardadasNotifier.new,
);

class FirmasGuardadasNotifier extends AsyncNotifier<List<FirmaGuardada>> {
  @override
  Future<List<FirmaGuardada>> build() {
    return ref.read(firmasRepositoryProvider).findMine();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(firmasRepositoryProvider).findMine());
  }

  Future<void> crear({
    required TipoFirma tipo,
    required List<int> bytes,
    required String fileName,
    String? etiqueta,
  }) async {
    await ref.read(firmasRepositoryProvider).create(
          tipo: tipo,
          bytes: bytes,
          fileName: fileName,
          etiqueta: etiqueta,
        );
    await refresh();
  }

  Future<void> eliminar(String id) async {
    await ref.read(firmasRepositoryProvider).remove(id);
    await refresh();
  }
}
