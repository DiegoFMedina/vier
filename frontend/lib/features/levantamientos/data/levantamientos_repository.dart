import 'package:dio/dio.dart';
import '../models/levantamiento.dart';

class LevantamientosRepository {
  LevantamientosRepository(this._dio);

  final Dio _dio;

  Future<List<Levantamiento>> findAll() async {
    final response = await _dio.get('/levantamientos');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => Levantamiento.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Levantamiento> create({
    required String titulo,
    String? descripcion,
    String? direccion,
  }) async {
    final response = await _dio.post('/levantamientos', data: {
      'titulo': titulo,
      if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
      if (direccion != null && direccion.isNotEmpty) 'direccion': direccion,
    });
    return Levantamiento.fromJson(response.data as Map<String, dynamic>);
  }
}
