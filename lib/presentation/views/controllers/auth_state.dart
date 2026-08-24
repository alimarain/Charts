import 'package:new_app/domain/entities/user.dart';


enum AuthStatus {
  unauthenticated,
  loading,
  authenticated,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.token,
    this.errorMessage,
  });

  final AuthStatus status;
  final User? user;
  final String? token;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated && token != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}