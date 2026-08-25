import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/core/errors/exceptions.dart';
import 'package:new_app/data/datasources/auth/auth_service.dart';

import 'auth_state.dart';

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

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(email, password);

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
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
