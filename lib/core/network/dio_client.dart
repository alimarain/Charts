import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/mock_http_adapter.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: 'https://example-api.com/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  );

  final dio = Dio(options);

  // Attach the mock adapter to simulate real HTTP requests locally
  dio.httpClientAdapter = MockHttpAdapter();

  // Attach interceptors for logging and JWT injection
  dio.interceptors.add(AuthInterceptor(ref));

  return dio;
});
