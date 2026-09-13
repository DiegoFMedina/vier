class Captura {
  const Captura({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.tipo,
    required this.createdAt,
    required this.url,
    required this.descargaUrl,
    this.notas,
    this.subidoPorNombre,
  });

  final String id;
  final String fileName;
  final String mimeType;
  final String tipo;
  final DateTime createdAt;
  final String url;
  final String descargaUrl;
  final String? notas;
  final String? subidoPorNombre;

  bool get esFoto => tipo == 'foto';

  factory Captura.fromJson(Map<String, dynamic> json) => Captura(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        mimeType: json['mimeType'] as String,
        tipo: json['tipo'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        url: json['url'] as String,
        descargaUrl: json['descargaUrl'] as String? ?? json['url'] as String,
        notas: json['notas'] as String?,
        subidoPorNombre: json['subidoPor']?['nombre'] as String?,
      );
}
