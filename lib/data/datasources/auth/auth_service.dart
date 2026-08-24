import '../../../core/errors/exceptions.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../domain/entities/user.dart';

class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.token,
  });

  final User user;
  final String token;
}

class AuthService {
  static const String _validEmail = 'demo@gmail.com';
  static const String _validPassword = '123456';

  Future<AuthResponse> login(String email, String password) async {
    // Simulate API network latency
    await Future.delayed(const Duration(milliseconds: 1500));

    if (email.trim().toLowerCase() == _validEmail && password == _validPassword) {
      const user = User(
        id: '1',
        name: 'Demo User',
        email: _validEmail,
        role: 'user',
      );

      final token = JwtUtils.generateMockToken(
        userId: user.id,
        email: user.email,
        role: user.role,
      );

      return AuthResponse(user: user, token: token);
    }

    throw const AuthException('Invalid email or password. Use demo@gmail.com / 123456');
  }
}