import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../theme/app_colors.dart';
import '../models/checklist_plantilla.dart';
import '../models/plantilla_grupo.dart';
import '../models/plantilla_item.dart';
import '../models/plantilla_seccion.dart';
import '../state/checklist_plantillas_provider.dart';

Future<String?> _promptText(
  BuildContext context, {
  required String titulo,
  String initial = '',
  int maxLines = 1,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: maxLines,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

Future<bool> _confirmar(BuildContext context, String mensaje) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.fucsia),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class ChecklistPlantillaBuilderScreen extends ConsumerStatefulWidget {
  const ChecklistPlantillaBuilderScreen({super.key, required this.plantillaId});

  final String plantillaId;

  @override
  ConsumerState<ChecklistPlantillaBuilderScreen> createState() =>
      _ChecklistPlantillaBuilderScreenState();
}

class _ChecklistPlantillaBuilderScreenState extends ConsumerState<ChecklistPlantillaBuilderScreen> {
  List<PlantillaSeccion>? _secciones;
  List<String>? _rolesFirma;
  bool _guardando = false;
  bool _subiendoLogo = false;

  List<PlantillaSeccion> get secciones => _secciones!;
  List<String> get rolesFirma => _rolesFirma!;

  void _sync(ChecklistPlantilla plantilla) {
    _secciones ??= List.of(plantilla.secciones);
    _rolesFirma ??= plantilla.rolesFirma.map((r) => r.nombre).toList();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await ref
          .read(checklistPlantillaDetalleProvider(widget.plantillaId).notifier)
          .guardarEstructura(secciones, rolesFirma: rolesFirma);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plantilla guardada')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la plantilla')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _agregarSeccion() async {
    final titulo = await _promptText(context, titulo: 'Nueva sección');
    if (titulo == null || titulo.isEmpty) return;
    setState(() => _secciones = [
          ...secciones,
          PlantillaSeccion(titulo: titulo, items: const [], grupos: const []),
        ]);
  }

  Future<void> _editarSeccion(int index) async {
    final titulo = await _promptText(context, titulo: 'Editar sección', initial: secciones[index].titulo);
    if (titulo == null || titulo.isEmpty) return;
    _actualizarSeccion(index, secciones[index].copyWith(titulo: titulo));
  }

  Future<void> _eliminarSeccion(int index) async {
    if (!await _confirmar(context, '¿Eliminar esta sección y todos sus ítems?')) return;
    setState(() => _secciones = List.of(secciones)..removeAt(index));
  }

  void _actualizarSeccion(int index, PlantillaSeccion nueva) {
    setState(() {
      final copia = List.of(secciones);
      copia[index] = nueva;
      _secciones = copia;
    });
  }

  Future<void> _agregarItem(int seccionIndex, {int? grupoIndex}) async {
    final descripcion = await _promptText(context, titulo: 'Nuevo ítem', maxLines: 3);
    if (descripcion == null || descripcion.isEmpty) return;
    final seccion = secciones[seccionIndex];
    if (grupoIndex == null) {
      _actualizarSeccion(
        seccionIndex,
        seccion.copyWith(items: [...seccion.items, PlantillaItem(descripcion: descripcion)]),
      );
    } else {
      final grupos = List.of(seccion.grupos);
      final grupo = grupos[grupoIndex];
      grupos[grupoIndex] = grupo.copyWith(items: [...grupo.items, PlantillaItem(descripcion: descripcion)]);
      _actualizarSeccion(seccionIndex, seccion.copyWith(grupos: grupos));
    }
  }

  Future<void> _editarItem(int seccionIndex, {int? grupoIndex, required int itemIndex}) async {
    final seccion = secciones[seccionIndex];
    final itemActual = grupoIndex == null ? seccion.items[itemIndex] : seccion.grupos[grupoIndex].items[itemIndex];
    final descripcion = await _promptText(
      context,
      titulo: 'Editar ítem',
      initial: itemActual.descripcion,
      maxLines: 3,
    );
    if (descripcion == null || descripcion.isEmpty) return;

    if (grupoIndex == null) {
      final items = List.of(seccion.items);
      items[itemIndex] = itemActual.copyWith(descripcion: descripcion);
      _actualizarSeccion(seccionIndex, seccion.copyWith(items: items));
    } else {
      final grupos = List.of(seccion.grupos);
      final items = List.of(grupos[grupoIndex].items);
      items[itemIndex] = itemActual.copyWith(descripcion: descripcion);
      grupos[grupoIndex] = grupos[grupoIndex].copyWith(items: items);
      _actualizarSeccion(seccionIndex, seccion.copyWith(grupos: grupos));
    }
  }

  Future<void> _eliminarItem(int seccionIndex, {int? grupoIndex, required int itemIndex}) async {
    if (!await _confirmar(context, '¿Eliminar este ítem?')) return;
    final seccion = secciones[seccionIndex];
    if (grupoIndex == null) {
      final items = List.of(seccion.items)..removeAt(itemIndex);
      _actualizarSeccion(seccionIndex, seccion.copyWith(items: items));
    } else {
      final grupos = List.of(seccion.grupos);
      final items = List.of(grupos[grupoIndex].items)..removeAt(itemIndex);
      grupos[grupoIndex] = grupos[grupoIndex].copyWith(items: items);
      _actualizarSeccion(seccionIndex, seccion.copyWith(grupos: grupos));
    }
  }

  Future<void> _agregarGrupo(int seccionIndex) async {
    final titulo = await _promptText(context, titulo: 'Nuevo subgrupo (opcional)');
    if (titulo == null || titulo.isEmpty) return;
    final seccion = secciones[seccionIndex];
    _actualizarSeccion(
      seccionIndex,
      seccion.copyWith(grupos: [...seccion.grupos, PlantillaGrupo(titulo: titulo, items: const [])]),
    );
  }

  Future<void> _eliminarGrupo(int seccionIndex, int grupoIndex) async {
    if (!await _confirmar(context, '¿Eliminar este subgrupo y todos sus ítems?')) return;
    final seccion = secciones[seccionIndex];
    final grupos = List.of(seccion.grupos)..removeAt(grupoIndex);
    _actualizarSeccion(seccionIndex, seccion.copyWith(grupos: grupos));
  }

  Future<void> _agregarRol() async {
    final nombre = await _promptText(context, titulo: 'Nuevo rol de firma (ej. "Jefe de Proyecto")');
    if (nombre == null || nombre.isEmpty) return;
    setState(() => _rolesFirma = [...rolesFirma, nombre]);
  }

  Future<void> _editarRol(int index) async {
    final nombre = await _promptText(context, titulo: 'Editar rol', initial: rolesFirma[index]);
    if (nombre == null || nombre.isEmpty) return;
    setState(() {
      final copia = List.of(rolesFirma);
      copia[index] = nombre;
      _rolesFirma = copia;
    });
  }

  Future<void> _eliminarRol(int index) async {
    if (!await _confirmar(context, '¿Eliminar este rol de firma?')) return;
    setState(() => _rolesFirma = List.of(rolesFirma)..removeAt(index));
  }

  Future<void> _subirLogo(String tipo) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _subiendoLogo = true);
      await ref.read(checklistPlantillaDetalleProvider(widget.plantillaId).notifier).subirLogo(
            tipo,
            bytes,
            file.name,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo subir el logo')));
      }
    } finally {
      if (mounted) setState(() => _subiendoLogo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantillaAsync = ref.watch(checklistPlantillaDetalleProvider(widget.plantillaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Plantilla de checklist')),
      body: plantillaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar la plantilla\n$err')),
        data: (plantilla) {
          _sync(plantilla);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              Text(plantilla.nombre, style: Theme.of(context).textTheme.titleLarge),
              if (plantilla.descripcion != null && plantilla.descripcion!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(plantilla.descripcion!, style: Theme.of(context).textTheme.bodySmall),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _LogoTile(
                      label: 'Logo empresa',
                      url: plantilla.logoEmpresaUrl,
                      loading: _subiendoLogo,
                      onTap: () => _subirLogo('empresa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LogoTile(
                      label: 'Logo cliente',
                      url: plantilla.logoClienteUrl,
                      loading: _subiendoLogo,
                      onTap: () => _subirLogo('cliente'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Roles de firma', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Quién debe firmar el documento (ej. Preparó, Revisó, Aprobó).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < rolesFirma.length; i++)
                    InputChip(
                      label: Text(rolesFirma[i]),
                      onPressed: () => _editarRol(i),
                      onDeleted: () => _eliminarRol(i),
                      deleteIconColor: AppColors.fucsia,
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18, color: AppColors.violetPrimary),
                    label: const Text('Agregar rol'),
                    onPressed: _agregarRol,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < secciones.length; i++) _buildSeccion(context, i),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _agregarSeccion,
                icon: const Icon(Icons.add),
                label: const Text('Agregar sección'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: CtaButton(
            label: 'Guardar cambios',
            icon: Icons.save_outlined,
            loading: _guardando,
            onPressed: _secciones == null ? null : _guardar,
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion(BuildContext context, int seccionIndex) {
    final seccion = secciones[seccionIndex];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text('${seccion.numero ?? seccionIndex + 1}. ${seccion.titulo}'),
        subtitle: Text('${seccion.totalItems} ítems'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'editar') _editarSeccion(seccionIndex);
            if (value == 'eliminar') _eliminarSeccion(seccionIndex);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'editar', child: Text('Renombrar')),
            PopupMenuItem(value: 'eliminar', child: Text('Eliminar sección')),
          ],
        ),
        children: [
          for (var i = 0; i < seccion.items.length; i++)
            _ItemTile(
              descripcion: seccion.items[i].descripcion,
              onEdit: () => _editarItem(seccionIndex, itemIndex: i),
              onDelete: () => _eliminarItem(seccionIndex, itemIndex: i),
            ),
          TextButton.icon(
            onPressed: () => _agregarItem(seccionIndex),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar ítem'),
          ),
          const Divider(height: 1),
          for (var g = 0; g < seccion.grupos.length; g++) _buildGrupo(context, seccionIndex, g),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextButton.icon(
              onPressed: () => _agregarGrupo(seccionIndex),
              icon: const Icon(Icons.playlist_add, size: 18),
              label: const Text('Agregar subgrupo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrupo(BuildContext context, int seccionIndex, int grupoIndex) {
    final grupo = secciones[seccionIndex].grupos[grupoIndex];
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(grupo.titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.fucsia),
                onPressed: () => _eliminarGrupo(seccionIndex, grupoIndex),
              ),
            ],
          ),
          for (var i = 0; i < grupo.items.length; i++)
            _ItemTile(
              descripcion: grupo.items[i].descripcion,
              onEdit: () => _editarItem(seccionIndex, grupoIndex: grupoIndex, itemIndex: i),
              onDelete: () => _eliminarItem(seccionIndex, grupoIndex: grupoIndex, itemIndex: i),
            ),
          TextButton.icon(
            onPressed: () => _agregarItem(seccionIndex, grupoIndex: grupoIndex),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar ítem'),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.descripcion, required this.onEdit, required this.onDelete});

  final String descripcion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.check_box_outlined, size: 18, color: AppColors.violetSoft),
      title: Text(descripcion),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.fucsia),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile({required this.label, required this.url, required this.onTap, required this.loading});

  final String label;
  final String? url;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.violetSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : url != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.network(url!, fit: BoxFit.contain),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined, color: AppColors.violetPrimary),
                      const SizedBox(height: 4),
                      Text(label, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
      ),
    );
  }
}
