import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/flat_illustration.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../levantamientos/models/levantamiento.dart';
import '../models/captura.dart';
import '../state/capturas_provider.dart';

class CapturaScreen extends ConsumerStatefulWidget {
  const CapturaScreen({super.key, required this.levantamientoId, this.levantamiento});

  final String levantamientoId;
  final Levantamiento? levantamiento;

  @override
  ConsumerState<CapturaScreen> createState() => _CapturaScreenState();
}

class _CapturaScreenState extends ConsumerState<CapturaScreen> {
  bool _subiendo = false;

  Future<void> _tomarFoto() => _capturar(ImageSource.camera);
  Future<void> _elegirGaleria() => _capturar(ImageSource.gallery);

  Future<void> _capturar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      // Calidad alta: son fotos de evidencia técnica (etiquetas, cableado,
      // equipos), conviene priorizar detalle sobre tamaño de archivo.
      final file = await picker.pickImage(source: source, imageQuality: 95);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      await _confirmarYSubir(bytes: bytes, fileName: file.name, mimeType: file.mimeType ?? 'image/jpeg');
    } catch (e) {
      _mostrarError('No se pudo capturar la foto');
    }
  }

  Future<void> _elegirDocumento() async {
    try {
      final files = await FilePicker.pickFiles();
      if (files.isEmpty) return;
      final picked = files.first;
      final bytes = await picked.readAsBytes();
      await _confirmarYSubir(
        bytes: bytes,
        fileName: picked.name,
        mimeType: _mimeFromName(picked.name),
      );
    } catch (e) {
      _mostrarError('No se pudo adjuntar el documento');
    }
  }

  String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _confirmarYSubir({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    final notas = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotasSheet(fileName: fileName),
    );
    if (notas == null) return;

    setState(() => _subiendo = true);
    try {
      await ref.read(capturasProvider(widget.levantamientoId).notifier).subir(
            bytes: bytes,
            fileName: fileName,
            mimeType: mimeType,
            notas: notas,
          );
    } catch (e) {
      _mostrarError('No se pudo subir la captura');
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  void _mostrarError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.fucsia),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capturasAsync = ref.watch(capturasProvider(widget.levantamientoId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levantamiento?.titulo ?? 'Captura en terreno'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Checklists',
            onPressed: () => context.push(
              '/levantamientos/${widget.levantamientoId}/checklists',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.levantamiento?.direccion != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(widget.levantamiento!.direccion!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          Expanded(
            child: capturasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error al cargar capturas\n$err')),
              data: (capturas) {
                if (capturas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FlatIllustration(size: 160, variant: IllustrationVariant.capture),
                          const SizedBox(height: 20),
                          Text('Sin capturas todavía', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            'Toma una foto o adjunta un documento del terreno',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: capturas.length,
                  itemBuilder: (context, index) => _CapturaTile(captura: capturas[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _subiendo
          ? const FloatingActionButton(onPressed: null, child: CircularProgressIndicator(color: Colors.white))
          : null,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: CtaButton(
                  label: 'Tomar foto',
                  icon: Icons.photo_camera_outlined,
                  loading: _subiendo,
                  onPressed: _tomarFoto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _subiendo ? null : () => _mostrarOpcionesArchivo(context),
                  icon: const Icon(Icons.attach_file, color: AppColors.violetPrimary),
                  label: const Text('Adjuntar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: AppColors.violetPrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarOpcionesArchivo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined, color: AppColors.violetPrimary),
              title: const Text('Elegir foto de galería'),
              onTap: () {
                Navigator.of(context).pop();
                _elegirGaleria();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.violetPrimary),
              title: const Text('Adjuntar documento (PDF u otro)'),
              onTap: () {
                Navigator.of(context).pop();
                _elegirDocumento();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CapturaTile extends StatelessWidget {
  const _CapturaTile({required this.captura});

  final Captura captura;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    captura.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (captura.notas != null && captura.notas!.isNotEmpty)
                    Text(
                      captura.notas!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotasSheet extends StatefulWidget {
  const _NotasSheet({required this.fileName});
  final String fileName;

  @override
  State<_NotasSheet> createState() => _NotasSheetState();
}

class _NotasSheetState extends State<_NotasSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Confirmar captura', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(widget.fileName, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Notas de la captura (opcional)'),
            ),
            const SizedBox(height: 20),
            CtaButton(
              label: 'Guardar captura',
              icon: Icons.check,
              onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
            ),
          ],
        ),
      ),
    );
  }
}
