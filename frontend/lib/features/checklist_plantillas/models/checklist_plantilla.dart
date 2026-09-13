import 'plantilla_seccion.dart';
import 'rol_firma.dart';

class ChecklistPlantilla {
  const ChecklistPlantilla({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.logoEmpresaUrl,
    this.logoClienteUrl,
    required this.activo,
    required this.updatedAt,
    this.totalSecciones = 0,
    this.totalInstancias = 0,
    this.secciones = const [],
    this.rolesFirma = const [],
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final String? logoEmpresaUrl;
  final String? logoClienteUrl;
  final bool activo;
  final DateTime updatedAt;
  final int totalSecciones;
  final int totalInstancias;
  final List<PlantillaSeccion> secciones;
  final List<RolFirma> rolesFirma;

  factory ChecklistPlantilla.fromJson(Map<String, dynamic> json) => ChecklistPlantilla(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        descripcion: json['descripcion'] as String?,
        logoEmpresaUrl: json['logoEmpresaUrl'] as String?,
        logoClienteUrl: json['logoClienteUrl'] as String?,
        activo: json['activo'] as bool? ?? true,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        totalSecciones: (json['_count']?['secciones'] as int?) ?? (json['secciones'] as List?)?.length ?? 0,
        totalInstancias: (json['_count']?['instancias'] as int?) ?? 0,
        secciones: (json['secciones'] as List<dynamic>?)
                ?.map((e) => PlantillaSeccion.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        rolesFirma: (json['rolesFirma'] as List<dynamic>?)
                ?.map((e) => RolFirma.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
