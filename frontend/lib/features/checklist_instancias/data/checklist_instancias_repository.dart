import 'package:dio/dio.dart';
import '../models/checklist_instancia.dart';
import '../models/instancia_firma.dart';

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

  Future<void> actualizarFirma(
    String instanciaId,
    String firmaId, {
    String? nombrePersona,
    String? fecha,
  }) async {
    await _dio.patch('/checklists/$instanciaId/firmas/$firmaId', data: {
      if (nombrePersona != null) 'nombrePersona': nombrePersona,
      if (fecha != null) 'fecha': fecha,
    });
  }

  Future<void> firmarConArchivo(
    String instanciaId,
    String firmaId, {
    required TipoFirma tipo,
    required List<int> bytes,
    required String fileName,
    String? guardarComo,
  }) async {
    final formData = FormData.fromMap({
      'tipo': tipo.toJson(),
      if (guardarComo != null) 'guardarComo': guardarComo,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    await _dio.post('/checklists/$instanciaId/firmas/$firmaId/imagen', data: formData);
  }

  Future<void> firmarConGuardada(String instanciaId, String firmaId, String firmaGuardadaId) async {
    await _dio.post('/checklists/$instanciaId/firmas/$firmaId/usar-guardada', data: {
      'firmaGuardadaId': firmaGuardadaId,
    });
  }

  Future<void> borrarFirma(String instanciaId, String firmaId) async {
    await _dio.delete('/checklists/$instanciaId/firmas/$firmaId/imagen');
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

  Future<List<int>> descargarDocx(String id) async {
    final response = await _dio.get<List<int>>(
      '/checklists/$id/docx',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}
