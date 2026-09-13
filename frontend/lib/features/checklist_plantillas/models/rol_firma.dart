class RolFirma {
  const RolFirma({this.id, required this.nombre});

  final String? id;
  final String nombre;

  factory RolFirma.fromJson(Map<String, dynamic> json) => RolFirma(
        id: json['id'] as String?,
        nombre: json['nombre'] as String,
      );
}
