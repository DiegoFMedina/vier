import 'plantilla_item.dart';

class PlantillaGrupo {
  const PlantillaGrupo({this.id, required this.titulo, required this.items});

  final String? id;
  final String titulo;
  final List<PlantillaItem> items;

  factory PlantillaGrupo.fromJson(Map<String, dynamic> json) => PlantillaGrupo(
        id: json['id'] as String?,
        titulo: json['titulo'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => PlantillaItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'items': items.map((e) => e.toJson()).toList(),
      };

  PlantillaGrupo copyWith({String? titulo, List<PlantillaItem>? items}) => PlantillaGrupo(
        id: id,
        titulo: titulo ?? this.titulo,
        items: items ?? this.items,
      );
}
