import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../theme/app_colors.dart';

/// Panel para dibujar una firma manuscrita con mouse/dedo/lápiz óptico.
/// Exponer [SignaturePadState] vía [GlobalKey] para leer/limpiar el trazo.
class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _trazos = [];
  final GlobalKey _boundaryKey = GlobalKey();

  bool get estaVacio => _trazos.isEmpty;

  void limpiar() => setState(_trazos.clear);

  void _onPanStart(DragStartDetails details) {
    setState(() => _trazos.add([details.localPosition]));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _trazos.last.add(details.localPosition));
  }

  Future<Uint8List?> exportarPng() async {
    if (_trazos.isEmpty) return null;
    final boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: CustomPaint(painter: _TrazoPainter(_trazos)),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrazoPainter extends CustomPainter {
  _TrazoPainter(this.trazos);
  final List<List<Offset>> trazos;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final trazo in trazos) {
      for (var i = 0; i < trazo.length - 1; i++) {
        canvas.drawLine(trazo[i], trazo[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrazoPainter oldDelegate) => true;
}
