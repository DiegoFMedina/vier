import '../../checklist_instancias/models/instancia_firma.dart';

class FirmaGuardada {
  const FirmaGuardada({
    required this.id,
    required this.etiqueta,
    required this.tipo,
    required this.url,
  });

  final String id;
  final String etiqueta;
  final TipoFirma tipo;
  final String url;

  factory FirmaGuardada.fromJson(Map<String, dynamic> json) => FirmaGuardada(
        id: json['id'] as String,
        etiqueta: json['etiqueta'] as String,
        tipo: TipoFirmaJson.fromJson(json['tipo'] as String?) ?? TipoFirma.foto,
        url: json['url'] as String,
      );
}
