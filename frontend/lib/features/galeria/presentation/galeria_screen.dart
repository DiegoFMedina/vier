import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/flat_illustration.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../levantamientos/state/levantamientos_provider.dart';

/// Lista de "álbumes": un álbum por levantamiento que ya tiene capturas.
class GaleriaScreen extends ConsumerWidget {
  const GaleriaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levantamientosAsync = ref.watch(levantamientosProvider);

    return RefreshIndicator(
        onRefresh: () => ref.read(levantamientosProvider.notifier).refresh(),
        child: levantamientosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error al cargar la galería\n$err')),
          data: (levantamientos) {
            final albumes = levantamientos.where((l) => l.capturasCount > 0).toList();

            if (albumes.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 60),
                  const Center(child: FlatIllustration(size: 160)),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('Aún no hay fotos', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Las capturas de cada levantamiento aparecerán aquí como álbumes',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemCount: albumes.length,
              itemBuilder: (context, index) {
                final album = albumes[index];
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/galeria/${album.id}', extra: album.titulo),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.violetSurface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.photo_library_outlined,
                                    color: AppColors.violetPrimary,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              album.titulo,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${album.capturasCount} capturas',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
  }
}
