class RevisionHistorial {
  const RevisionHistorial({
    required this.revision,
    required this.descripcion,
    this.aprobacionGerenciaGeneral,
    this.aprobacionDeptoIngenieria,
    this.aprobacionClienteJefeProyecto,
  });

  final String revision;
  final String descripcion;
  final String? aprobacionGerenciaGeneral;
  final String? aprobacionDeptoIngenieria;
  final String? aprobacionClienteJefeProyecto;

  factory RevisionHistorial.fromJson(Map<String, dynamic> json) => RevisionHistorial(
        revision: json['revision'] as String,
        descripcion: json['descripcion'] as String,
        aprobacionGerenciaGeneral: json['aprobacionGerenciaGeneral'] as String?,
        aprobacionDeptoIngenieria: json['aprobacionDeptoIngenieria'] as String?,
        aprobacionClienteJefeProyecto: json['aprobacionClienteJefeProyecto'] as String?,
      );
}
