import 'dart:html' as html;
import 'dart:typed_data';

void abrirPdfEnNuevaPestana(Uint8List bytes, String nombreArchivo) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
}

void abrirDocxEnNuevaPestana(Uint8List bytes, String nombreArchivo) {
  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
}
