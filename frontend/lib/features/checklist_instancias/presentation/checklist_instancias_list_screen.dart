import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/flat_illustration.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../checklist_plantillas/state/checklist_plantillas_provider.dart';
import '../models/checklist_instancia.dart';
import '../state/checklist_instancias_provider.dart';

class ChecklistInstanciasListScreen extends ConsumerWidget {
  const ChecklistInstanciasListScreen({super.key, required this.levantamientoId});

  final String levantamientoId;

  Color _estadoColor(ChecklistEstado estado) {
    switch (estado) {
      case ChecklistEstado.enRevision:
        return AppColors.orangeSoft;
      case ChecklistEstado.aprobado:
        return const Color(0xFF34A853);
      case ChecklistEstado.borrador:
        return AppColors.violetSoft;
    }
  }

  Future<void> _elegirPlantilla(BuildContext context, WidgetRef ref) async {
    final plantillasAsync = ref.read(checklistPlantillasProvider);
    final plantillas = plantillasAsync.value?.where((p) => p.activo).toList() ?? [];

    if (plantillas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay plantillas de checklist disponibles. Crea una primero.')),
      );
      return;
    }

    final plantillaId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Elegir plantilla', style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final plantilla in plantillas)
              ListTile(
                leading: const Icon(Icons.fact_check_outlined, color: AppColors.violetPrimary),
                title: Text(plantilla.nombre),
                subtitle: Text('${plantilla.totalSecciones} secciones'),
                onTap: () => Navigator.of(context).pop(plantilla.id),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (plantillaId == null) return;

    final creada = await ref
        .read(checklistInstanciasPorLevantamientoProvider(levantamientoId).notifier)
        .crear(plantillaId);
    if (context.mounted) {
      context.push('/checklists/${creada.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instanciasAsync = ref.watch(checklistInstanciasPorLevantamientoProvider(levantamientoId));
    ref.watch(checklistPlantillasProvider);
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return Scaffold(
      appBar: AppBar(title: const Text('Checklists')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _elegirPlantilla(context, ref),
        backgroundColor: AppColors.violetPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo checklist'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(checklistInstanciasPorLevantamientoProvider(levantamientoId).notifier).refresh(),
        child: instanciasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error al cargar checklists\n$err')),
          data: (instancias) {
            if (instancias.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 60),
                  const Center(child: FlatIllustration(size: 160)),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('Sin checklists todavía', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Crea uno a partir de una plantilla',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: instancias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final instancia = instancias[index];
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
                      onTap: () => context.push('/checklists/${instancia.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(instancia.nombre, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Text(
                                    dateFormat.format(instancia.updatedAt),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _estadoColor(instancia.estado).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                instancia.estado.label,
                                style: TextStyle(
                                  color: _estadoColor(instancia.estado),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
      ),
    );
  }
}
