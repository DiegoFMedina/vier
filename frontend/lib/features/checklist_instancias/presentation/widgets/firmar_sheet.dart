import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/cta_button.dart';
import '../../../../shared/widgets/signature_pad.dart';
import '../../../../theme/app_colors.dart';
import '../../../firmas/state/firmas_provider.dart';
import '../../models/instancia_firma.dart';

sealed class FirmarResultado {}

class FirmarConImagen extends FirmarResultado {
  FirmarConImagen({
    required this.bytes,
    required this.fileName,
    required this.tipo,
    this.guardarComo,
  });

  final List<int> bytes;
  final String fileName;
  final TipoFirma tipo;
  final String? guardarComo;
}

class FirmarConGuardada extends FirmarResultado {
  FirmarConGuardada(this.firmaGuardadaId);
  final String firmaGuardadaId;
}

Future<FirmarResultado?> mostrarFirmarSheet(BuildContext context) {
  return showModalBottomSheet<FirmarResultado>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _FirmarSheet(),
  );
}

class _FirmarSheet extends ConsumerStatefulWidget {
  const _FirmarSheet();

  @override
  ConsumerState<_FirmarSheet> createState() => _FirmarSheetState();
}

class _FirmarSheetState extends ConsumerState<_FirmarSheet> {
  int _tab = 0;
  final _padKey = GlobalKey<SignaturePadState>();
  final _etiquetaController = TextEditingController();
  bool _guardarParaReusar = false;

  @override
  void dispose() {
    _etiquetaController.dispose();
    super.dispose();
  }

  Future<void> _confirmarDibujo() async {
    final bytes = await _padKey.currentState?.exportarPng();
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dibuja tu firma primero')));
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop(
        FirmarConImagen(
          bytes: bytes,
          fileName: 'firma-${DateTime.now().millisecondsSinceEpoch}.png',
          tipo: TipoFirma.dibujada,
          guardarComo: _guardarParaReusar ? (_etiquetaController.text.trim().isEmpty ? 'Mi firma' : _etiquetaController.text.trim()) : null,
        ),
      );
    }
  }

  Future<void> _elegirFoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) {
      Navigator.of(context).pop(
        FirmarConImagen(
          bytes: bytes,
          fileName: file.name,
          tipo: TipoFirma.foto,
          guardarComo: _guardarParaReusar ? (_etiquetaController.text.trim().isEmpty ? 'Mi firma' : _etiquetaController.text.trim()) : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmasGuardadasAsync = ref.watch(firmasGuardadasProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Firmar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _TabButton(label: 'Dibujar', selected: _tab == 0, onTap: () => setState(() => _tab = 0))),
                const SizedBox(width: 8),
                Expanded(child: _TabButton(label: 'Subir foto', selected: _tab == 1, onTap: () => setState(() => _tab = 1))),
                const SizedBox(width: 8),
                Expanded(child: _TabButton(label: 'Guardadas', selected: _tab == 2, onTap: () => setState(() => _tab = 2))),
              ],
            ),
            const SizedBox(height: 16),
            if (_tab == 0) ...[
              SignaturePad(key: _padKey),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _padKey.currentState?.limpiar(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Borrar'),
                ),
              ),
              _GuardarParaReusarField(
                checked: _guardarParaReusar,
                onChanged: (v) => setState(() => _guardarParaReusar = v),
                controller: _etiquetaController,
              ),
              const SizedBox(height: 12),
              CtaButton(label: 'Usar esta firma', icon: Icons.check, onPressed: _confirmarDibujo),
            ] else if (_tab == 1) ...[
              Text(
                'Sube una foto de la firma en papel.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _GuardarParaReusarField(
                checked: _guardarParaReusar,
                onChanged: (v) => setState(() => _guardarParaReusar = v),
                controller: _etiquetaController,
              ),
              const SizedBox(height: 12),
              CtaButton(label: 'Elegir foto', icon: Icons.photo_camera_outlined, onPressed: _elegirFoto),
            ] else
              SizedBox(
                height: 260,
                child: firmasGuardadasAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error al cargar firmas guardadas\n$err')),
                  data: (firmas) {
                    if (firmas.isEmpty) {
                      return const Center(child: Text('No tienes firmas guardadas todavía'));
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 160,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: firmas.length,
                      itemBuilder: (context, index) {
                        final firma = firmas[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).pop(FirmarConGuardada(firma.id)),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.network(firma.url, fit: BoxFit.contain),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    firma.etiqueta,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GuardarParaReusarField extends StatelessWidget {
  const _GuardarParaReusarField({required this.checked, required this.onChanged, required this.controller});

  final bool checked;
  final ValueChanged<bool> onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: checked,
          onChanged: (v) => onChanged(v ?? false),
          title: const Text('Guardar esta firma para reutilizarla después'),
        ),
        if (checked)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Etiqueta (ej. "Mi firma")'),
            ),
          ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.violetPrimary : AppColors.violetSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
