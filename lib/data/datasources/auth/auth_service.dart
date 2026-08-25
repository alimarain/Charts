import '../../../core/errors/exceptions.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../domain/entities/user.dart';

class AuthResponse {
  const AuthResponse({required this.user, required this.token});

  final User user;
  final String token;
}

class AuthService {
  static const String _userEmail = 'demo@gmail.com';
  static const String _userPassword = '123456';

  static const String _makerEmail = 'applicant@example.com';
  static const String _makerPassword = 'applicant@123';

  Future<AuthResponse> login(
    String email,
    String password, {
    String selectedRole = 'user',
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final cleanEmail = email.trim().toLowerCase();

    if (selectedRole == 'maker') {
      if (cleanEmail == _makerEmail && password == _makerPassword) {
        const user = User(
          id: 'applicant-01',
          name: 'ali',
          email: _makerEmail,
          role: 'maker',
        );

        final token = JwtUtils.generateMockToken(
          userId: user.id,
          email: user.email,
          role: user.role,
        );

        return AuthResponse(user: user, token: token);
      }
      throw const AuthException(
        'Invalid Maker credentials. Use applicant@example.com / applicant@123',
      );
    } else {
      if (cleanEmail == _userEmail && password == _userPassword) {
        const user = User(
          id: 'user-01',
          name: 'Demo User',
          email: _userEmail,
          role: 'user',
        );

        final token = JwtUtils.generateMockToken(
          userId: user.id,
          email: user.email,
          role: user.role,
        );

        return AuthResponse(user: user, token: token);
      }
      throw const AuthException(
        'Invalid User credentials. Use demo@gmail.com / 123456',
      );
    }
  }
}
