import 'package:dio/dio.dart';
import '../models/checklist_instancia.dart';

class ChecklistInstanciasRepository {
  ChecklistInstanciasRepository(this._dio);

  final Dio _dio;

  Future<List<ChecklistInstanciaResumen>> findByLevantamiento(String levantamientoId) async {
    final response = await _dio.get('/levantamientos/$levantamientoId/checklists');
    return (response.data as List<dynamic>)
        .map((e) => ChecklistInstanciaResumen.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChecklistInstancia> create(String levantamientoId, String plantillaId) async {
    final response = await _dio.post('/levantamientos/$levantamientoId/checklists', data: {
      'plantillaId': plantillaId,
    });
    return ChecklistInstancia.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChecklistInstancia> findOne(String id) async {
    final response = await _dio.get('/checklists/$id');
    return ChecklistInstancia.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch('/checklists/$id', data: data);
  }

  Future<void> responderItem(String instanciaId, String itemId, {String? valor, String? observaciones}) async {
    await _dio.patch('/checklists/$instanciaId/items/$itemId', data: {
      'valor': valor,
      if (observaciones != null) 'observaciones': observaciones,
    });
  }

  Future<void> agregarRevision(String instanciaId, Map<String, dynamic> data) async {
    await _dio.post('/checklists/$instanciaId/revisiones', data: data);
  }

  Future<void> subirLogo(String instanciaId, String tipo, List<int> bytes, String fileName) async {
    final formData = FormData.fromMap({
      'tipo': tipo,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    await _dio.post('/checklists/$instanciaId/logo', data: formData);
  }

  Future<void> remove(String id) async {
    await _dio.delete('/checklists/$id');
  }

  Future<List<int>> descargarPdf(String id) async {
    final response = await _dio.get<List<int>>(
      '/checklists/$id/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}
