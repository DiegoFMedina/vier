import 'package:dio/dio.dart';
import '../models/checklist_plantilla.dart';
import '../models/plantilla_seccion.dart';

class ChecklistPlantillasRepository {
  ChecklistPlantillasRepository(this._dio);

  final Dio _dio;

  Future<List<ChecklistPlantilla>> findAll() async {
    final response = await _dio.get('/checklist-plantillas');
    return (response.data as List<dynamic>)
        .map((e) => ChecklistPlantilla.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChecklistPlantilla> findOne(String id) async {
    final response = await _dio.get('/checklist-plantillas/$id');
    return ChecklistPlantilla.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChecklistPlantilla> create({
    required String nombre,
    String? descripcion,
    String? duplicarDeId,
  }) async {
    final response = await _dio.post('/checklist-plantillas', data: {
      'nombre': nombre,
      if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
      if (duplicarDeId != null) 'duplicarDeId': duplicarDeId,
    });
    return ChecklistPlantilla.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChecklistPlantilla> update(String id, {String? nombre, String? descripcion, bool? activo}) async {
    final response = await _dio.patch('/checklist-plantillas/$id', data: {
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (activo != null) 'activo': activo,
    });
    return ChecklistPlantilla.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChecklistPlantilla> reemplazarEstructura(String id, List<PlantillaSeccion> secciones) async {
    final response = await _dio.put('/checklist-plantillas/$id/estructura', data: {
      'secciones': secciones.map((s) => s.toJson()).toList(),
    });
    return ChecklistPlantilla.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChecklistPlantilla> subirLogo(String id, String tipo, List<int> bytes, String fileName) async {
    final formData = FormData.fromMap({
      'tipo': tipo,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await _dio.post('/checklist-plantillas/$id/logo', data: formData);
    return ChecklistPlantilla.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> remove(String id) async {
    await _dio.delete('/checklist-plantillas/$id');
  }
}
