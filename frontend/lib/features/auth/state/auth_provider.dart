import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/token_storage.dart';
import '../data/auth_repository.dart';
import 'auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restoreSession);
    return const AuthState.checking();
  }

  Future<void> _restoreSession() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.read();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await ref.read(authRepositoryProvider).me(token);
      state = AuthState(status: AuthStatus.authenticated, token: token, user: user);
    } catch (_) {
      await storage.clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final result = await ref.read(authRepositoryProvider).login(email, password);
      await ref.read(tokenStorageProvider).save(result.token);
      state = AuthState(
        status: AuthStatus.authenticated,
        token: result.token,
        user: result.user,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
