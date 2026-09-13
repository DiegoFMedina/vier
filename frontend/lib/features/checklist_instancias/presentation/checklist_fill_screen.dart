import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/pdf_viewer_web.dart';
import '../../../theme/app_colors.dart';
import '../models/instancia_grupo.dart';
import '../models/instancia_item.dart';
import '../models/instancia_seccion.dart';
import '../state/checklist_instancias_provider.dart';

class ChecklistFillScreen extends ConsumerStatefulWidget {
  const ChecklistFillScreen({super.key, required this.instanciaId});

  final String instanciaId;

  @override
  ConsumerState<ChecklistFillScreen> createState() => _ChecklistFillScreenState();
}

class _ChecklistFillScreenState extends ConsumerState<ChecklistFillScreen> {
  bool _generandoPdf = false;

  Future<void> _verPdf() async {
    setState(() => _generandoPdf = true);
    try {
      final repo = ref.read(checklistInstanciasRepositoryProvider);
      final bytes = await repo.descargarPdf(widget.instanciaId);
      abrirPdfEnNuevaPestana(Uint8List.fromList(bytes), 'checklist-${widget.instanciaId}.pdf');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar el PDF')),
        );
      }
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final instanciaAsync = ref.watch(checklistInstanciaDetalleProvider(widget.instanciaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Datos del documento',
            onPressed: () => context.push('/checklists/${widget.instanciaId}/datos'),
          ),
          IconButton(
            icon: _generandoPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Ver PDF',
            onPressed: _generandoPdf ? null : _verPdf,
          ),
        ],
      ),
      body: instanciaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar el checklist\n$err')),
        data: (instancia) {
          final total = instancia.totalItems;
          final respondidos = instancia.totalRespondidos;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              Text(instancia.nombre, style: Theme.of(context).textTheme.titleLarge),
              if (instancia.estacion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(instancia.estacion!, style: Theme.of(context).textTheme.bodySmall),
                ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : respondidos / total,
                  minHeight: 8,
                  backgroundColor: AppColors.violetSurface,
                  color: AppColors.violetPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text('$respondidos de $total ítems respondidos', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              for (final seccion in instancia.secciones) _SeccionCard(instanciaId: widget.instanciaId, seccion: seccion),
            ],
          );
        },
      ),
    );
  }
}

class _SeccionCard extends StatelessWidget {
  const _SeccionCard({required this.instanciaId, required this.seccion});

  final String instanciaId;
  final InstanciaSeccion seccion;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text('${seccion.numero}. ${seccion.titulo}'),
        subtitle: Text('${seccion.respondidos}/${seccion.total} respondidos'),
        children: [
          for (final item in seccion.items) _ItemRespuestaTile(instanciaId: instanciaId, item: item),
          for (final grupo in seccion.grupos) _GrupoBloque(instanciaId: instanciaId, grupo: grupo),
        ],
      ),
    );
  }
}

class _GrupoBloque extends StatelessWidget {
  const _GrupoBloque({required this.instanciaId, required this.grupo});

  final String instanciaId;
  final InstanciaGrupo grupo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(grupo.titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
          for (final item in grupo.items) _ItemRespuestaTile(instanciaId: instanciaId, item: item),
        ],
      ),
    );
  }
}

class _ItemRespuestaTile extends ConsumerStatefulWidget {
  const _ItemRespuestaTile({required this.instanciaId, required this.item});

  final String instanciaId;
  final InstanciaItem item;

  @override
  ConsumerState<_ItemRespuestaTile> createState() => _ItemRespuestaTileState();
}

class _ItemRespuestaTileState extends ConsumerState<_ItemRespuestaTile> {
  late final TextEditingController _observaciones =
      TextEditingController(text: widget.item.observaciones ?? '');
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChange);

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _guardarObservaciones();
  }

  Future<void> _guardarObservaciones() async {
    if (_observaciones.text.trim() == (widget.item.observaciones ?? '')) return;
    await ref.read(checklistInstanciaDetalleProvider(widget.instanciaId).notifier).responderItem(
          widget.item.id,
          valor: widget.item.valor?.toJson(),
          observaciones: _observaciones.text.trim(),
        );
  }

  Future<void> _elegir(RespuestaChecklist? valor) async {
    final nuevo = widget.item.valor == valor ? null : valor;
    await ref.read(checklistInstanciaDetalleProvider(widget.instanciaId).notifier).responderItem(
          widget.item.id,
          valor: nuevo?.toJson(),
          observaciones: _observaciones.text.trim(),
        );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(widget.item.descripcion)),
              const SizedBox(width: 8),
              _Toggle(label: 'SI', selected: widget.item.valor == RespuestaChecklist.si, onTap: () => _elegir(RespuestaChecklist.si)),
              const SizedBox(width: 6),
              _Toggle(label: 'NO', selected: widget.item.valor == RespuestaChecklist.no, onTap: () => _elegir(RespuestaChecklist.no)),
            ],
          ),
          if (widget.item.requiereObservacion) ...[
            const SizedBox(height: 6),
            TextField(
              controller: _observaciones,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Observaciones',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.violetPrimary : AppColors.violetSurface,
          borderRadius: BorderRadius.circular(10),
        ),
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
