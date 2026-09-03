import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/datasources/auth/api_auth_service.dart';
import '../../domain/entities/user.dart';

final authServiceProvider = Provider<ApiAuthService>((ref) {
  return ApiAuthService(ref.watch(dioProvider));
});

class AuthState {
  final User? user;
  final String? token;
  final String? selectedRole;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.token,
    this.selectedRole,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null && token != null;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(
    String email,
    String password, {
    String? selectedRole,
  }) async {
    state = AuthState(isLoading: true, selectedRole: selectedRole);
    try {
      final (token, user) = await ref
          .read(authServiceProvider)
          .login(email, password);

      await ref
          .read(tokenStorageProvider)
          .saveSession(
            token: token,
            userId: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
          );

      state = AuthState(
        user: user,
        token: token,
        selectedRole: selectedRole ?? user.role,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        selectedRole: selectedRole,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearSession();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
