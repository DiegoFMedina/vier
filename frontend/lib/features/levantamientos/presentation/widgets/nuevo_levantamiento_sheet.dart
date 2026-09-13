import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/cta_button.dart';
import '../../../../theme/app_colors.dart';
import '../../state/levantamientos_provider.dart';

Future<void> showNuevoLevantamientoSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NuevoLevantamientoSheet(),
  );
}

class _NuevoLevantamientoSheet extends ConsumerStatefulWidget {
  const _NuevoLevantamientoSheet();

  @override
  ConsumerState<_NuevoLevantamientoSheet> createState() => _NuevoLevantamientoSheetState();
}

class _NuevoLevantamientoSheetState extends ConsumerState<_NuevoLevantamientoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _direccionController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _direccionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(levantamientosProvider.notifier).crear(
            titulo: _tituloController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            direccion: _direccionController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo crear el levantamiento')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Iniciar levantamiento', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Registra los datos base antes de salir a terreno',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(hintText: 'Título (ej. Sucursal Providencia)'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(hintText: 'Dirección / ubicación'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Notas u objetivo del levantamiento'),
              ),
              const SizedBox(height: 24),
              CtaButton(label: 'Crear levantamiento', loading: _loading, onPressed: _guardar),
            ],
          ),
        ),
      ),
    );
  }
}
