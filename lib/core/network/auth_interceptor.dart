import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/presentation/controllers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Read JWT directly from Riverpod authentication state as single source of truth
    final token = _ref.read(authProvider).token;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final hasAuthHeader = options.headers.containsKey('Authorization');
    final authLog = hasAuthHeader ? 'Bearer [attached]' : 'None';

    developer.log(
      '--> ${options.method.toUpperCase()} ${options.uri}\n    Authorization: $authLog',
      name: 'Dio.Request',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.path}',
      name: 'Dio.Response',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '<-- ERROR ${err.response?.statusCode ?? "NO_STATUS"} ${err.requestOptions.uri}\n    Message: ${err.message}',
      name: 'Dio.Error',
    );
    handler.next(err);
  }
}
