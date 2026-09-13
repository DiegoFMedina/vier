import 'dart:html' as html;
import 'dart:typed_data';

void abrirPdfEnNuevaPestana(Uint8List bytes, String nombreArchivo) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
}

/// Navega directamente a [url] (sin pasar por blob). A diferencia de un PDF,
/// un .docx no se puede previsualizar dentro del navegador: hace falta que
/// sea una descarga real (con el Content-Disposition: attachment de la
/// respuesta) para que Safari en iPhone la reconozca y ofrezca guardarla; un
/// blob generado desde Dart no dispara ese flujo de forma confiable ahí.
void abrirUrlEnNuevaPestana(String url) {
  html.window.open(url, '_blank');
}
