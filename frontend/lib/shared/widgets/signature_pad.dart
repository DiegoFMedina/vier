import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
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

  static const double _strokeWidth = 2.6;
  static const double _padding = 24;
  static const double _pixelRatio = 3.0;

  bool get estaVacio => _trazos.isEmpty;

  void limpiar() => setState(_trazos.clear);

  void _onPanStart(DragStartDetails details) {
    setState(() => _trazos.add([details.localPosition]));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _trazos.last.add(details.localPosition));
  }

  /// Exporta solo el trazo dibujado, recortado ajustado a su tinta (con un
  /// margen), en vez de todo el lienzo (que ahora ocupa la pantalla
  /// completa). Si se exportara el lienzo entero, una firma compacta
  /// terminaría como una mancha diminuta en medio de una imagen casi en
  /// blanco, e ilegible al incrustarla en el PDF.
  Future<Uint8List?> exportarPng() async {
    if (_trazos.isEmpty) return null;

    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (final trazo in _trazos) {
      for (final p in trazo) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
    }

    final width = (maxX - minX) + _padding * 2;
    final height = (maxY - minY) + _padding * 2;
    final offset = Offset(minX - _padding, minY - _padding);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(_pixelRatio);

    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final trazo in _trazos) {
      for (var i = 0; i < trazo.length - 1; i++) {
        canvas.drawLine(trazo[i] - offset, trazo[i + 1] - offset, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (width * _pixelRatio).round(),
      (height * _pixelRatio).round(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          child: SizedBox.expand(
            child: CustomPaint(painter: _TrazoPainter(_trazos)),
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
      ..strokeWidth = SignaturePadState._strokeWidth
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
