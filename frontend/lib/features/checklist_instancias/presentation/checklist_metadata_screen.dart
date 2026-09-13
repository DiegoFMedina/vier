import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/cta_button.dart';
import '../models/checklist_instancia.dart';
import '../state/checklist_instancias_provider.dart';

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
  final _preparadoPor = TextEditingController();
  final _revisadoPor = TextEditingController();
  final _aprobadoPor = TextEditingController();

  DateTime? _fecha;
  DateTime? _preparadoFecha;
  DateTime? _revisadoFecha;
  DateTime? _aprobadoFecha;

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
    _preparadoPor.text = instancia.preparadoPorNombre ?? '';
    _revisadoPor.text = instancia.revisadoPorNombre ?? '';
    _aprobadoPor.text = instancia.aprobadoPorNombre ?? '';
    _fecha = instancia.fecha;
    _preparadoFecha = instancia.preparadoPorFecha;
    _revisadoFecha = instancia.revisadoPorFecha;
    _aprobadoFecha = instancia.aprobadoPorFecha;
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

  String _fmt(DateTime? d) => d == null ? 'Sin fecha' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
        if (_preparadoPor.text.trim().isNotEmpty) 'preparadoPorNombre': _preparadoPor.text.trim(),
        if (_preparadoFecha != null) 'preparadoPorFecha': _preparadoFecha!.toIso8601String(),
        if (_revisadoPor.text.trim().isNotEmpty) 'revisadoPorNombre': _revisadoPor.text.trim(),
        if (_revisadoFecha != null) 'revisadoPorFecha': _revisadoFecha!.toIso8601String(),
        if (_aprobadoPor.text.trim().isNotEmpty) 'aprobadoPorNombre': _aprobadoPor.text.trim(),
        if (_aprobadoFecha != null) 'aprobadoPorFecha': _aprobadoFecha!.toIso8601String(),
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
    for (final c in [
      _contrato,
      _docCliente,
      _docInterno,
      _estacion,
      _revision,
      _comentarios,
      _preparadoPor,
      _revisadoPor,
      _aprobadoPor,
    ]) {
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
              const SizedBox(height: 24),
              Text('Preparó / Revisó / Aprobó', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _FirmaRow(
                label: 'Preparó',
                nombreController: _preparadoPor,
                fecha: _preparadoFecha,
                onFecha: () => _elegirFecha(_preparadoFecha, (d) => setState(() => _preparadoFecha = d)),
                fechaLabel: _fmt(_preparadoFecha),
              ),
              const SizedBox(height: 12),
              _FirmaRow(
                label: 'Revisó',
                nombreController: _revisadoPor,
                fecha: _revisadoFecha,
                onFecha: () => _elegirFecha(_revisadoFecha, (d) => setState(() => _revisadoFecha = d)),
                fechaLabel: _fmt(_revisadoFecha),
              ),
              const SizedBox(height: 12),
              _FirmaRow(
                label: 'Aprobó',
                nombreController: _aprobadoPor,
                fecha: _aprobadoFecha,
                onFecha: () => _elegirFecha(_aprobadoFecha, (d) => setState(() => _aprobadoFecha = d)),
                fechaLabel: _fmt(_aprobadoFecha),
              ),
              const SizedBox(height: 24),
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

class _FirmaRow extends StatelessWidget {
  const _FirmaRow({
    required this.label,
    required this.nombreController,
    required this.fecha,
    required this.onFecha,
    required this.fechaLabel,
  });

  final String label;
  final TextEditingController nombreController;
  final DateTime? fecha;
  final VoidCallback onFecha;
  final String fechaLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 70, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Expanded(
          child: TextField(controller: nombreController, decoration: const InputDecoration(hintText: 'Nombre')),
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: onFecha, child: Text(fechaLabel)),
      ],
    );
  }
}
