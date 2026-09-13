import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../theme/app_colors.dart';
import '../models/checklist_instancia.dart';
import '../models/instancia_firma.dart';
import '../state/checklist_instancias_provider.dart';
import 'widgets/firmar_sheet.dart';

class ChecklistMetadataScreen extends ConsumerStatefulWidget {
  const ChecklistMetadataScreen({super.key, required this.instanciaId});

  final String instanciaId;

  @override
  ConsumerState<ChecklistMetadataScreen> createState() => _ChecklistMetadataScreenState();
}

class _ChecklistMetadataScreenState extends ConsumerState<ChecklistMetadataScreen> {
  final _contrato = TextEditingController();
  final _docCliente = TextEditingController();
  final _docInterno = TextEditingController();
  final _estacion = TextEditingController();
  final _revision = TextEditingController();
  final _comentarios = TextEditingController();

  DateTime? _fecha;

  bool _cargado = false;
  bool _guardando = false;

  void _sync(ChecklistInstancia instancia) {
    if (_cargado) return;
    _cargado = true;
    _contrato.text = instancia.contratoNumero ?? '';
    _docCliente.text = instancia.numeroDocumentoCliente ?? '';
    _docInterno.text = instancia.numeroDocumentoInterno ?? '';
    _estacion.text = instancia.estacion ?? '';
    _revision.text = instancia.revisionActual;
    _comentarios.text = instancia.comentarios ?? '';
    _fecha = instancia.fecha;
  }

  Future<void> _elegirFecha(DateTime? actual, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: actual ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  String _fmt(DateTime? d) => d == null
      ? 'Sin fecha'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await ref.read(checklistInstanciaDetalleProvider(widget.instanciaId).notifier).actualizarMetadata({
        'contratoNumero': _contrato.text.trim(),
        'numeroDocumentoCliente': _docCliente.text.trim(),
        'numeroDocumentoInterno': _docInterno.text.trim(),
        'estacion': _estacion.text.trim(),
        'revisionActual': _revision.text.trim().isEmpty ? 'A' : _revision.text.trim(),
        'comentarios': _comentarios.text.trim(),
        if (_fecha != null) 'fecha': _fecha!.toIso8601String(),
      });
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo guardar')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_contrato, _docCliente, _docInterno, _estacion, _revision, _comentarios]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instanciaAsync = ref.watch(checklistInstanciaDetalleProvider(widget.instanciaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Datos del documento')),
      body: instanciaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error\n$err')),
        data: (instancia) {
          _sync(instancia);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              Text('Contrato', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(controller: _contrato, decoration: const InputDecoration(hintText: 'N° de contrato')),
              const SizedBox(height: 12),
              TextField(controller: _docCliente, decoration: const InputDecoration(hintText: 'N° documento cliente')),
              const SizedBox(height: 12),
              TextField(controller: _docInterno, decoration: const InputDecoration(hintText: 'N° documento interno')),
              const SizedBox(height: 12),
              TextField(controller: _estacion, decoration: const InputDecoration(hintText: 'Estación / sitio')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _revision,
                      decoration: const InputDecoration(hintText: 'Revisión (ej. A)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _elegirFecha(_fecha, (d) => setState(() => _fecha = d)),
                      child: Text(_fmt(_fecha)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Firmantes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Los roles se configuran en la plantilla. Firmar es opcional.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final firma in instancia.firmas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FirmanteCard(instanciaId: widget.instanciaId, firma: firma),
                ),
              const SizedBox(height: 16),
              Text('Comentarios generales', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: _comentarios,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(hintText: 'Comentarios adicionales para el documento'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: CtaButton(label: 'Guardar', loading: _guardando, onPressed: _guardar),
        ),
      ),
    );
  }
}

class _FirmanteCard extends ConsumerStatefulWidget {
  const _FirmanteCard({required this.instanciaId, required this.firma});

  final String instanciaId;
  final InstanciaFirma firma;

  @override
  ConsumerState<_FirmanteCard> createState() => _FirmanteCardState();
}

class _FirmanteCardState extends ConsumerState<_FirmanteCard> {
  late final TextEditingController _nombre = TextEditingController(text: widget.firma.nombrePersona ?? '');
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChange);
  bool _procesando = false;

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _guardarNombre();
  }

  Future<void> _guardarNombre() async {
    if (_nombre.text.trim() == (widget.firma.nombrePersona ?? '')) return;
    await ref
        .read(checklistInstanciaDetalleProvider(widget.instanciaId).notifier)
        .actualizarFirma(widget.firma.id, nombrePersona: _nombre.text.trim());
  }

  Future<void> _elegirFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.firma.fecha ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    await ref
        .read(checklistInstanciaDetalleProvider(widget.instanciaId).notifier)
        .actualizarFirma(widget.firma.id, fecha: picked.toIso8601String());
  }

  Future<void> _firmar() async {
    final resultado = await mostrarFirmarSheet(context);
    if (resultado == null) return;
    setState(() => _procesando = true);
    try {
      final notifier = ref.read(checklistInstanciaDetalleProvider(widget.instanciaId).notifier);
      switch (resultado) {
        case FirmarConImagen r:
          await notifier.firmarConArchivo(
            widget.firma.id,
            tipo: r.tipo,
            bytes: r.bytes,
            fileName: r.fileName,
            guardarComo: r.guardarComo,
          );
        case FirmarConGuardada r:
          await notifier.firmarConGuardada(widget.firma.id, r.firmaGuardadaId);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo guardar la firma')));
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _quitarFirma() async {
    setState(() => _procesando = true);
    try {
      await ref.read(checklistInstanciaDetalleProvider(widget.instanciaId).notifier).borrarFirma(widget.firma.id);
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  String _fmt(DateTime? d) => d == null
      ? 'Sin fecha'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void dispose() {
    _focusNode.dispose();
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.firma.rolNombre, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombre,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(hintText: 'Nombre'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _elegirFecha, child: Text(_fmt(widget.firma.fecha))),
              ],
            ),
            const SizedBox(height: 10),
            if (_procesando)
              const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
            else if (widget.firma.firmado) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.network(widget.firma.firmaUrl!, height: 60, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _firmar,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Volver a firmar'),
                  ),
                  TextButton.icon(
                    onPressed: _quitarFirma,
                    style: TextButton.styleFrom(foregroundColor: AppColors.fucsia),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Quitar'),
                  ),
                ],
              ),
            ] else
              OutlinedButton.icon(
                onPressed: _firmar,
                icon: const Icon(Icons.draw_outlined, color: AppColors.violetPrimary),
                label: const Text('Firmar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: AppColors.violetPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
