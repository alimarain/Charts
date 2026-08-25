import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/presentation/views/controllers/auth_state.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/auth/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String password, {String selectedRole = 'user'}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(email, password, selectedRole: selectedRole);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        token: response.token,
      );
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected connection error occurred.',
      );
    }
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}