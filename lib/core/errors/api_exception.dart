import 'package:dio/dio.dart';

enum ApiErrorType {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  networkError,
  cancel,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errorType = ApiErrorType.unknown,
  });

  final String message;
  final int? statusCode;
  final ApiErrorType errorType;

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Connection failed. Please check your internet connection.',
          errorType: ApiErrorType.networkError,
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'The request was cancelled.',
          errorType: ApiErrorType.cancel,
        );

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        switch (statusCode) {
          case 400:
            return ApiException(
              message: 'Invalid request. Please check submitted data.',
              statusCode: statusCode,
              errorType: ApiErrorType.badRequest,
            );
          case 401:
            return ApiException(
              message: 'Unauthorized. Please login again.',
              statusCode: statusCode,
              errorType: ApiErrorType.unauthorized,
            );
          case 403:
            return ApiException(
              message: 'Access forbidden. You do not have permission.',
              statusCode: statusCode,
              errorType: ApiErrorType.forbidden,
            );
          case 404:
            return ApiException(
              message: 'Requested resource was not found.',
              statusCode: statusCode,
              errorType: ApiErrorType.notFound,
            );
          case 500:
          case 502:
          case 503:
            return ApiException(
              message: 'Server error encountered. Please try again later.',
              statusCode: statusCode,
              errorType: ApiErrorType.serverError,
            );
          default:
            return ApiException(
              message: 'Received invalid status code: $statusCode',
              statusCode: statusCode,
              errorType: ApiErrorType.unknown,
            );
        }

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      default:
        return const ApiException(
          message: 'An unexpected network error occurred.',
          errorType: ApiErrorType.unknown,
        );
    }
  }

  @override
  String toString() => 'ApiException [$statusCode | $errorType]: $message';
}
