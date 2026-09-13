enum AuthStatus { checking, authenticated, unauthenticated }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.nombre,
    required this.role,
  });

  final String id;
  final String email;
  final String nombre;
  final String role;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        nombre: json['nombre'] as String,
        role: json['role'] as String,
      );
}

class AuthState {
  const AuthState({required this.status, this.token, this.user, this.errorMessage});

  final AuthStatus status;
  final String? token;
  final AppUser? user;
  final String? errorMessage;

  const AuthState.checking() : this(status: AuthStatus.checking);

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
