import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/state/auth_provider.dart';
import 'env.dart';

final apiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authNotifierProvider).token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  return dio;
});
