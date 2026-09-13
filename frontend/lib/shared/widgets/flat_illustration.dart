import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Ilustración vectorial plana (flat design) de un personaje simplificado
/// analizando datos/gestión en terreno. Dibujada a mano con formas simples
/// para no depender de assets externos.
class FlatIllustration extends StatelessWidget {
  const FlatIllustration({super.key, this.size = 180, this.variant = IllustrationVariant.analytics});

  final double size;
  final IllustrationVariant variant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IllustrationPainter(variant: variant),
      ),
    );
  }
}

enum IllustrationVariant { analytics, empty, capture }

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter({required this.variant});

  final IllustrationVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final backdrop = Paint()..color = AppColors.violetSurface;
    canvas.drawCircle(Offset(w * 0.5, h * 0.52), w * 0.46, backdrop);

    // Base / suelo
    final base = Paint()..color = AppColors.violetSoft.withValues(alpha: 0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.88), width: w * 0.6, height: h * 0.08), base);

    // Cuerpo (personaje)
    final body = Paint()..color = AppColors.violetPrimary;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.34, h * 0.42, w * 0.32, h * 0.36),
      Radius.circular(w * 0.1),
    );
    canvas.drawRRect(bodyRect, body);

    // Cabeza
    final head = Paint()..color = const Color(0xFFFFD9B0);
    canvas.drawCircle(Offset(w * 0.5, h * 0.34), w * 0.11, head);

    // Cabello
    final hair = Paint()..color = AppColors.violetDeep;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.33), radius: w * 0.12),
      3.4,
      3.1,
      true,
      hair,
    );

    // Brazo sosteniendo tablet/clipboard
    final arm = Paint()..color = AppColors.violetPrimary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.6, h * 0.5, w * 0.16, h * 0.09),
        Radius.circular(w * 0.05),
      ),
      arm,
    );

    // Tablet / documento con gráfico (accento fucsia + naranja)
    final clipboard = Paint()..color = Colors.white;
    final clipboardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.66, h * 0.4, w * 0.2, h * 0.26),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(clipboardRect, clipboard);
    canvas.drawRRect(
      clipboardRect,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    if (variant == IllustrationVariant.empty) {
      // Barras de gráfico dentro del documento
      final barColors = [AppColors.fucsia, AppColors.orangeSoft, AppColors.violetPrimary];
      for (var i = 0; i < 3; i++) {
        final barHeight = h * (0.04 + i * 0.03);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * (0.70 + i * 0.055),
              h * 0.6 - barHeight,
              w * 0.035,
              barHeight,
            ),
            Radius.circular(w * 0.015),
          ),
          Paint()..color = barColors[i],
        );
      }
    } else if (variant == IllustrationVariant.capture) {
      // Icono de cámara
      final camPaint = Paint()..color = AppColors.fucsia;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.7, h * 0.46, w * 0.12, h * 0.09),
          Radius.circular(w * 0.02),
        ),
        camPaint,
      );
      canvas.drawCircle(Offset(w * 0.76, h * 0.505), w * 0.03, Paint()..color = Colors.white);
    } else {
      final barColors = [AppColors.fucsia, AppColors.orangeSoft];
      for (var i = 0; i < 2; i++) {
        final barHeight = h * (0.05 + i * 0.04);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * (0.71 + i * 0.07),
              h * 0.62 - barHeight,
              w * 0.045,
              barHeight,
            ),
            Radius.circular(w * 0.02),
          ),
          Paint()..color = barColors[i],
        );
      }
    }

    // Lupa flotante (análisis)
    final magnifierRing = Paint()
      ..color = AppColors.orangeSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;
    canvas.drawCircle(Offset(w * 0.25, h * 0.62), w * 0.06, magnifierRing);
    canvas.drawLine(
      Offset(w * 0.29, h * 0.66),
      Offset(w * 0.34, h * 0.71),
      Paint()
        ..color = AppColors.orangeSoft
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) => oldDelegate.variant != variant;
}
