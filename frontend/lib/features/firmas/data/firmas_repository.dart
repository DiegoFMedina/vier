import 'package:dio/dio.dart';
import '../../checklist_instancias/models/instancia_firma.dart';
import '../models/firma_guardada.dart';

class FirmasRepository {
  FirmasRepository(this._dio);

  final Dio _dio;

  Future<List<FirmaGuardada>> findMine() async {
    final response = await _dio.get('/firmas');
    return (response.data as List<dynamic>)
        .map((e) => FirmaGuardada.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required TipoFirma tipo,
    required List<int> bytes,
    required String fileName,
    String? etiqueta,
  }) async {
    final formData = FormData.fromMap({
      'tipo': tipo.toJson(),
      if (etiqueta != null && etiqueta.isNotEmpty) 'etiqueta': etiqueta,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    await _dio.post('/firmas', data: formData);
  }

  Future<void> remove(String id) async {
    await _dio.delete('/firmas/$id');
  }
}
