import 'dart:html' as html;

/// Abre la URL de descarga en una pestaña nueva. El backend firma esta URL
/// con Content-Disposition: attachment y el nombre original del archivo, así
/// que el navegador la guarda directamente en vez de mostrarla inline —no se
/// necesita el atributo HTML "download" (que de todas formas no funciona
/// para URLs de otro origen, como la de MinIO).
void descargarArchivo(String url) {
  html.window.open(url, '_blank');
}
