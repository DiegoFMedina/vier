import 'instancia_grupo.dart';
import 'instancia_item.dart';

class InstanciaSeccion {
  const InstanciaSeccion({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.items,
    required this.grupos,
  });

  final String id;
  final int numero;
  final String titulo;
  final List<InstanciaItem> items;
  final List<InstanciaGrupo> grupos;

  int get total => items.length + grupos.fold(0, (sum, g) => sum + g.items.length);
  int get respondidos =>
      items.where((i) => i.valor != null).length +
      grupos.fold(0, (sum, g) => sum + g.items.where((i) => i.valor != null).length);

  factory InstanciaSeccion.fromJson(Map<String, dynamic> json) => InstanciaSeccion(
        id: json['id'] as String,
        numero: json['numero'] as int,
        titulo: json['titulo'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => InstanciaItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        grupos: (json['grupos'] as List<dynamic>)
            .map((e) => InstanciaGrupo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
