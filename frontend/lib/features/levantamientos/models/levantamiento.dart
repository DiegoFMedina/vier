class Levantamiento {
  const Levantamiento({
    required this.id,
    required this.titulo,
    required this.estado,
    required this.createdAt,
    required this.capturasCount,
    this.descripcion,
    this.direccion,
    this.creadoPorNombre,
  });

  final String id;
  final String titulo;
  final String? descripcion;
  final String? direccion;
  final String estado;
  final DateTime createdAt;
  final int capturasCount;
  final String? creadoPorNombre;

  factory Levantamiento.fromJson(Map<String, dynamic> json) => Levantamiento(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String?,
        direccion: json['direccion'] as String?,
        estado: json['estado'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        capturasCount: (json['_count']?['capturas'] as int?) ?? 0,
        creadoPorNombre: json['creadoPor']?['nombre'] as String?,
      );

  String get estadoLabel {
    switch (estado) {
      case 'EN_PROGRESO':
        return 'En progreso';
      case 'COMPLETADO':
        return 'Completado';
      default:
        return 'Pendiente';
    }
  }
}
