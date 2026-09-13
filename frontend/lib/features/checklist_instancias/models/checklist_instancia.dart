import 'instancia_seccion.dart';
import 'revision_historial.dart';

enum ChecklistEstado { borrador, enRevision, aprobado }

extension ChecklistEstadoJson on ChecklistEstado {
  String toJson() {
    switch (this) {
      case ChecklistEstado.borrador:
        return 'BORRADOR';
      case ChecklistEstado.enRevision:
        return 'EN_REVISION';
      case ChecklistEstado.aprobado:
        return 'APROBADO';
    }
  }

  String get label {
    switch (this) {
      case ChecklistEstado.borrador:
        return 'Borrador';
      case ChecklistEstado.enRevision:
        return 'En revisión';
      case ChecklistEstado.aprobado:
        return 'Aprobado';
    }
  }

  static ChecklistEstado fromJson(String value) {
    switch (value) {
      case 'EN_REVISION':
        return ChecklistEstado.enRevision;
      case 'APROBADO':
        return ChecklistEstado.aprobado;
      default:
        return ChecklistEstado.borrador;
    }
  }
}

class ChecklistInstancia {
  const ChecklistInstancia({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.levantamientoId,
    this.logoEmpresaUrl,
    this.logoClienteUrl,
    this.contratoNumero,
    this.numeroDocumentoCliente,
    this.numeroDocumentoInterno,
    this.estacion,
    this.revisionActual = 'A',
    this.fecha,
    this.preparadoPorNombre,
    this.preparadoPorFecha,
    this.revisadoPorNombre,
    this.revisadoPorFecha,
    this.aprobadoPorNombre,
    this.aprobadoPorFecha,
    this.comentarios,
    this.secciones = const [],
    this.revisiones = const [],
  });

  final String id;
  final String nombre;
  final ChecklistEstado estado;
  final String levantamientoId;
  final String? logoEmpresaUrl;
  final String? logoClienteUrl;
  final String? contratoNumero;
  final String? numeroDocumentoCliente;
  final String? numeroDocumentoInterno;
  final String? estacion;
  final String revisionActual;
  final DateTime? fecha;
  final String? preparadoPorNombre;
  final DateTime? preparadoPorFecha;
  final String? revisadoPorNombre;
  final DateTime? revisadoPorFecha;
  final String? aprobadoPorNombre;
  final DateTime? aprobadoPorFecha;
  final String? comentarios;
  final List<InstanciaSeccion> secciones;
  final List<RevisionHistorial> revisiones;

  int get totalItems => secciones.fold(0, (sum, s) => sum + s.total);
  int get totalRespondidos => secciones.fold(0, (sum, s) => sum + s.respondidos);

  static DateTime? _fecha(dynamic value) => value == null ? null : DateTime.parse(value as String);

  factory ChecklistInstancia.fromJson(Map<String, dynamic> json) => ChecklistInstancia(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        estado: ChecklistEstadoJson.fromJson(json['estado'] as String),
        levantamientoId: json['levantamientoId'] as String,
        logoEmpresaUrl: json['logoEmpresaUrl'] as String?,
        logoClienteUrl: json['logoClienteUrl'] as String?,
        contratoNumero: json['contratoNumero'] as String?,
        numeroDocumentoCliente: json['numeroDocumentoCliente'] as String?,
        numeroDocumentoInterno: json['numeroDocumentoInterno'] as String?,
        estacion: json['estacion'] as String?,
        revisionActual: json['revisionActual'] as String? ?? 'A',
        fecha: _fecha(json['fecha']),
        preparadoPorNombre: json['preparadoPorNombre'] as String?,
        preparadoPorFecha: _fecha(json['preparadoPorFecha']),
        revisadoPorNombre: json['revisadoPorNombre'] as String?,
        revisadoPorFecha: _fecha(json['revisadoPorFecha']),
        aprobadoPorNombre: json['aprobadoPorNombre'] as String?,
        aprobadoPorFecha: _fecha(json['aprobadoPorFecha']),
        comentarios: json['comentarios'] as String?,
        secciones: (json['secciones'] as List<dynamic>?)
                ?.map((e) => InstanciaSeccion.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        revisiones: (json['revisiones'] as List<dynamic>?)
                ?.map((e) => RevisionHistorial.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class ChecklistInstanciaResumen {
  const ChecklistInstanciaResumen({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.updatedAt,
    required this.totalSecciones,
  });

  final String id;
  final String nombre;
  final ChecklistEstado estado;
  final DateTime updatedAt;
  final int totalSecciones;

  factory ChecklistInstanciaResumen.fromJson(Map<String, dynamic> json) => ChecklistInstanciaResumen(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        estado: ChecklistEstadoJson.fromJson(json['estado'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        totalSecciones: (json['_count']?['secciones'] as int?) ?? 0,
      );
}
