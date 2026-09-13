class AprobacionRevision {
  const AprobacionRevision({required this.rol, this.valor});

  final String rol;
  final String? valor;

  factory AprobacionRevision.fromJson(Map<String, dynamic> json) => AprobacionRevision(
        rol: json['rol'] as String,
        valor: json['valor'] as String?,
      );

  Map<String, dynamic> toJson() => {'rol': rol, 'valor': valor};
}

class RevisionHistorial {
  const RevisionHistorial({
    required this.revision,
    required this.descripcion,
    this.aprobaciones = const [],
  });

  final String revision;
  final String descripcion;
  final List<AprobacionRevision> aprobaciones;

  factory RevisionHistorial.fromJson(Map<String, dynamic> json) => RevisionHistorial(
        revision: json['revision'] as String,
        descripcion: json['descripcion'] as String,
        aprobaciones: (json['aprobaciones'] as List<dynamic>?)
                ?.map((e) => AprobacionRevision.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
