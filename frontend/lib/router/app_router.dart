import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/state/auth_models.dart';
import '../features/auth/state/auth_provider.dart';
import '../features/capturas/presentation/captura_screen.dart';
import '../features/levantamientos/models/levantamiento.dart';
import '../features/levantamientos/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final onLogin = state.matchedLocation == '/login';

      if (auth.status == AuthStatus.checking) return null;
      if (auth.status == AuthStatus.unauthenticated) return onLogin ? null : '/login';
      if (auth.status == AuthStatus.authenticated && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/levantamientos/:id/capturas',
        builder: (context, state) => CapturaScreen(
          levantamientoId: state.pathParameters['id']!,
          levantamiento: state.extra as Levantamiento?,
        ),
      ),
    ],
  );
});

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }

  final Ref _ref;
}
