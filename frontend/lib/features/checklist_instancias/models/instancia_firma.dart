enum TipoFirma { dibujada, foto }

extension TipoFirmaJson on TipoFirma {
  String toJson() => this == TipoFirma.dibujada ? 'DIBUJADA' : 'FOTO';

  static TipoFirma? fromJson(String? value) {
    switch (value) {
      case 'DIBUJADA':
        return TipoFirma.dibujada;
      case 'FOTO':
        return TipoFirma.foto;
      default:
        return null;
    }
  }
}

class InstanciaFirma {
  const InstanciaFirma({
    required this.id,
    required this.rolNombre,
    required this.orden,
    this.nombrePersona,
    this.fecha,
    this.firmaUrl,
    this.firmaTipo,
  });

  final String id;
  final String rolNombre;
  final int orden;
  final String? nombrePersona;
  final DateTime? fecha;
  final String? firmaUrl;
  final TipoFirma? firmaTipo;

  bool get firmado => firmaUrl != null;

  factory InstanciaFirma.fromJson(Map<String, dynamic> json) => InstanciaFirma(
        id: json['id'] as String,
        rolNombre: json['rolNombre'] as String,
        orden: json['orden'] as int,
        nombrePersona: json['nombrePersona'] as String?,
        fecha: json['fecha'] != null ? DateTime.parse(json['fecha'] as String) : null,
        firmaUrl: json['firmaUrl'] as String?,
        firmaTipo: TipoFirmaJson.fromJson(json['firmaTipo'] as String?),
      );
}
