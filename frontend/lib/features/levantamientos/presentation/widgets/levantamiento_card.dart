import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../models/levantamiento.dart';

class LevantamientoCard extends StatelessWidget {
  const LevantamientoCard({super.key, required this.levantamiento, required this.onTap});

  final Levantamiento levantamiento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');
    final estadoColor = AppColors.estadoColor(levantamiento.estado);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        levantamiento.titulo,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: estadoColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        levantamiento.estadoLabel,
                        style: TextStyle(
                          color: estadoColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (levantamiento.direccion != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          levantamiento.direccion!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.violetSoft),
                    const SizedBox(width: 4),
                    Text(
                      '${levantamiento.capturasCount} capturas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(levantamiento.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
