import 'package:dio/dio.dart';
import '../../../core/env.dart';
import '../state/auth_models.dart';

class AuthRepository {
  AuthRepository() : _dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  final Dio _dio;

  Future<({String token, AppUser user})> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      return (
        token: data['accessToken'] as String,
        user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<AppUser> me(String token) async {
    final response = await _dio.get(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }

  String _messageFor(DioException e) {
    if (e.response?.statusCode == 401) {
      return 'Correo o contraseña incorrectos';
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'No se pudo conectar con el servidor';
    }
    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
