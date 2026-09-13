class PlantillaItem {
  const PlantillaItem({this.id, required this.descripcion, this.requiereObservacion = true});

  final String? id;
  final String descripcion;
  final bool requiereObservacion;

  factory PlantillaItem.fromJson(Map<String, dynamic> json) => PlantillaItem(
        id: json['id'] as String?,
        descripcion: json['descripcion'] as String,
        requiereObservacion: json['requiereObservacion'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'descripcion': descripcion,
        'requiereObservacion': requiereObservacion,
      };

  PlantillaItem copyWith({String? descripcion, bool? requiereObservacion}) => PlantillaItem(
        id: id,
        descripcion: descripcion ?? this.descripcion,
        requiereObservacion: requiereObservacion ?? this.requiereObservacion,
      );
}
