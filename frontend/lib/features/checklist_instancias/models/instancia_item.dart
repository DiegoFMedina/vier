enum RespuestaChecklist { si, no }

extension RespuestaChecklistJson on RespuestaChecklist {
  String toJson() => this == RespuestaChecklist.si ? 'SI' : 'NO';

  static RespuestaChecklist? fromJson(String? value) {
    switch (value) {
      case 'SI':
        return RespuestaChecklist.si;
      case 'NO':
        return RespuestaChecklist.no;
      default:
        return null;
    }
  }
}

class InstanciaItem {
  const InstanciaItem({
    required this.id,
    required this.descripcion,
    required this.requiereObservacion,
    this.valor,
    this.observaciones,
  });

  final String id;
  final String descripcion;
  final bool requiereObservacion;
  final RespuestaChecklist? valor;
  final String? observaciones;

  factory InstanciaItem.fromJson(Map<String, dynamic> json) => InstanciaItem(
        id: json['id'] as String,
        descripcion: json['descripcion'] as String,
        requiereObservacion: json['requiereObservacion'] as bool? ?? true,
        valor: RespuestaChecklistJson.fromJson(json['valor'] as String?),
        observaciones: json['observaciones'] as String?,
      );
}
