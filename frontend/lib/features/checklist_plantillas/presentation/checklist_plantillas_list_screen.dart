import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/flat_illustration.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../state/checklist_plantillas_provider.dart';

class ChecklistPlantillasListScreen extends ConsumerWidget {
  const ChecklistPlantillasListScreen({super.key});

  Future<void> _crear(BuildContext context, WidgetRef ref) async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva plantilla de checklist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(nombreController.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    if (nombre == null || nombre.isEmpty) return;

    final creada = await ref.read(checklistPlantillasProvider.notifier).crear(
          nombre: nombre,
          descripcion: descripcionController.text.trim(),
        );
    if (context.mounted) {
      context.push('/checklist-plantillas/${creada.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantillasAsync = ref.watch(checklistPlantillasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plantillas de checklist')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context, ref),
        backgroundColor: AppColors.violetPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(checklistPlantillasProvider.notifier).refresh(),
        child: plantillasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error al cargar plantillas\n$err')),
          data: (plantillas) {
            if (plantillas.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 60),
                  const Center(child: FlatIllustration(size: 160)),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('Aún no tienes plantillas', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Crea una plantilla reutilizable de checklist',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: plantillas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final plantilla = plantillas[index];
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
                      onTap: () => context.push('/checklist-plantillas/${plantilla.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plantilla.nombre, style: Theme.of(context).textTheme.titleMedium),
                                  if (plantilla.descripcion != null && plantilla.descripcion!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        plantilla.descripcion!,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${plantilla.totalSecciones} secciones · usada en ${plantilla.totalInstancias} levantamientos',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.violetSoft),
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
      ),
    );
  }
}
