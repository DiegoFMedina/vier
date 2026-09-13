import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../data/levantamientos_repository.dart';
import '../models/levantamiento.dart';

final levantamientosRepositoryProvider = Provider<LevantamientosRepository>((ref) {
  return LevantamientosRepository(ref.watch(apiDioProvider));
});

final levantamientosProvider =
    AsyncNotifierProvider<LevantamientosNotifier, List<Levantamiento>>(
  LevantamientosNotifier.new,
);

class LevantamientosNotifier extends AsyncNotifier<List<Levantamiento>> {
  @override
  Future<List<Levantamiento>> build() {
    return ref.read(levantamientosRepositoryProvider).findAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(levantamientosRepositoryProvider).findAll());
  }

  Future<void> crear({
    required String titulo,
    String? descripcion,
    String? direccion,
  }) async {
    await ref.read(levantamientosRepositoryProvider).create(
          titulo: titulo,
          descripcion: descripcion,
          direccion: direccion,
        );
    await refresh();
  }
}
