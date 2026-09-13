import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/download_web.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../capturas/models/captura.dart';
import '../../capturas/state/capturas_provider.dart';

/// Grilla de fotos/documentos de un levantamiento (un "álbum" de la
/// galería), de solo lectura, con opción de ver en grande y descargar el
/// archivo original (misma calidad con la que se subió).
class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key, required this.levantamientoId, this.titulo});

  final String levantamientoId;
  final String? titulo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturasAsync = ref.watch(capturasProvider(levantamientoId));

    return Scaffold(
      appBar: AppBar(title: Text(titulo ?? 'Álbum')),
      body: capturasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar las capturas\n$err')),
        data: (capturas) {
          if (capturas.isEmpty) {
            return const Center(child: Text('Sin capturas en este levantamiento'));
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemCount: capturas.length,
            itemBuilder: (context, index) => _AlbumTile(captura: capturas[index]),
          );
        },
      ),
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({required this.captura});

  final Captura captura;

  void _abrirVisor(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _VisorCaptura(captura: captura),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _abrirVisor(context),
                    child: captura.esFoto
                        ? Image.network(
                            captura.url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const ColoredBox(
                              color: AppColors.violetSurface,
                              child: Icon(Icons.broken_image_outlined, color: AppColors.violetSoft),
                            ),
                          )
                        : ColoredBox(
                            color: AppColors.violetSurface,
                            child: Center(
                              child: Icon(Icons.description, size: 40, color: AppColors.violetPrimary),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    captura.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.download_outlined, color: Colors.white, size: 18),
                  tooltip: 'Descargar original',
                  onPressed: () => descargarArchivo(captura.descargaUrl),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisorCaptura extends StatelessWidget {
  const _VisorCaptura({required this.captura});

  final Captura captura;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: captura.esFoto
                ? InteractiveViewer(
                    child: Image.network(captura.url, fit: BoxFit.contain),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(40),
                      child: Icon(Icons.description, size: 80, color: AppColors.violetPrimary),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => descargarArchivo(captura.descargaUrl),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Descargar original'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.violetPrimary),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
