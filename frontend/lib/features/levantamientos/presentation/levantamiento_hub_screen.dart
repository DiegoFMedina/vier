import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../capturas/state/capturas_provider.dart';
import '../../checklist_instancias/state/checklist_instancias_provider.dart';
import '../models/levantamiento.dart';

class LevantamientoHubScreen extends ConsumerWidget {
  const LevantamientoHubScreen({super.key, required this.levantamientoId, this.levantamiento});

  final String levantamientoId;
  final Levantamiento? levantamiento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturasAsync = ref.watch(capturasProvider(levantamientoId));
    final checklistsAsync = ref.watch(checklistInstanciasPorLevantamientoProvider(levantamientoId));

    return Scaffold(
      appBar: AppBar(title: Text(levantamiento?.titulo ?? 'Levantamiento')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          if (levantamiento?.direccion != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(levantamiento!.direccion!, style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          if (levantamiento?.descripcion != null && levantamiento!.descripcion!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(levantamiento!.descripcion!, style: Theme.of(context).textTheme.bodyMedium),
            ),
          const SizedBox(height: 20),
          Text('Tareas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _TaskCard(
            icon: Icons.fact_check_outlined,
            titulo: 'Checklist',
            subtitulo: checklistsAsync.when(
              data: (items) => items.isEmpty
                  ? 'Sin checklist todavía'
                  : '${items.length} checklist${items.length == 1 ? '' : 's'}',
              loading: () => 'Cargando...',
              error: (_, __) => 'Error al cargar',
            ),
            onTap: () => context.push('/levantamientos/$levantamientoId/checklists'),
          ),
          const SizedBox(height: 14),
          _TaskCard(
            icon: Icons.photo_camera_outlined,
            titulo: 'Capturas en terreno',
            subtitulo: capturasAsync.when(
              data: (items) => items.isEmpty ? 'Sin capturas todavía' : '${items.length} capturas',
              loading: () => 'Cargando...',
              error: (_, __) => 'Error al cargar',
            ),
            onTap: () => context.push(
              '/levantamientos/$levantamientoId/capturas',
              extra: levantamiento,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.violetSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.violetPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(subtitulo, style: Theme.of(context).textTheme.bodySmall),
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
  }
}
