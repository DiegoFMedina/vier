import 'instancia_item.dart';

class InstanciaGrupo {
  const InstanciaGrupo({required this.id, required this.titulo, required this.items});

  final String id;
  final String titulo;
  final List<InstanciaItem> items;

  factory InstanciaGrupo.fromJson(Map<String, dynamic> json) => InstanciaGrupo(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => InstanciaItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
