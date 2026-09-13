import 'package:dio/dio.dart';
import '../models/captura.dart';

class CapturasRepository {
  CapturasRepository(this._dio);

  final Dio _dio;

  Future<List<Captura>> findByLevantamiento(String levantamientoId) async {
    final response = await _dio.get('/levantamientos/$levantamientoId/capturas');
    final data = response.data as List<dynamic>;
    return data.map((e) => Captura.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Captura> upload({
    required String levantamientoId,
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    String? notas,
    double? latitud,
    double? longitud,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      if (notas != null && notas.isNotEmpty) 'notas': notas,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
    });
    final response = await _dio.post(
      '/levantamientos/$levantamientoId/capturas',
      data: formData,
    );
    final capturas = await findByLevantamiento(levantamientoId);
    final createdId = response.data['id'] as String;
    return capturas.firstWhere((c) => c.id == createdId, orElse: () => capturas.first);
  }

  Future<void> remove(String id) async {
    await _dio.delete('/capturas/$id');
  }
}
