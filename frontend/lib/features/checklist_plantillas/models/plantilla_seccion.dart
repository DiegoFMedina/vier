import 'plantilla_grupo.dart';
import 'plantilla_item.dart';

class PlantillaSeccion {
  const PlantillaSeccion({
    this.id,
    this.numero,
    required this.titulo,
    required this.items,
    required this.grupos,
  });

  final String? id;
  final int? numero;
  final String titulo;
  final List<PlantillaItem> items;
  final List<PlantillaGrupo> grupos;

  factory PlantillaSeccion.fromJson(Map<String, dynamic> json) => PlantillaSeccion(
        id: json['id'] as String?,
        numero: json['numero'] as int?,
        titulo: json['titulo'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => PlantillaItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        grupos: (json['grupos'] as List<dynamic>)
            .map((e) => PlantillaGrupo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'items': items.map((e) => e.toJson()).toList(),
        'grupos': grupos.map((e) => e.toJson()).toList(),
      };

  int get totalItems => items.length + grupos.fold(0, (sum, g) => sum + g.items.length);

  PlantillaSeccion copyWith({
    String? titulo,
    List<PlantillaItem>? items,
    List<PlantillaGrupo>? grupos,
  }) =>
      PlantillaSeccion(
        id: id,
        numero: numero,
        titulo: titulo ?? this.titulo,
        items: items ?? this.items,
        grupos: grupos ?? this.grupos,
      );
}
