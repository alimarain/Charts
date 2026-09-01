import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../../../domain/entities/user.dart';

class ApiAuthService {
  final Dio _dio;
  ApiAuthService(this._dio);

  Future<(String token, User user)> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final token = apiResponse.data!['accessToken'] as String;
        final userMap = apiResponse.data!['user'] as Map<String, dynamic>;

        final user = User(
          id: userMap['id'] as String,
          name: userMap['name'] as String,
          email: userMap['email'] as String,
          role: userMap['role'] as String,
        );

        return (token, user);
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Authentication failed.';
      throw Exception(msg);
    }
  }
}