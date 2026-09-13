import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/state/auth_models.dart';
import '../features/auth/state/auth_provider.dart';
import '../features/capturas/presentation/captura_screen.dart';
import '../features/checklist_instancias/presentation/checklist_fill_screen.dart';
import '../features/checklist_instancias/presentation/checklist_instancias_list_screen.dart';
import '../features/checklist_instancias/presentation/checklist_metadata_screen.dart';
import '../features/checklist_plantillas/presentation/checklist_plantilla_builder_screen.dart';
import '../features/checklist_plantillas/presentation/checklist_plantillas_list_screen.dart';
import '../features/galeria/presentation/album_screen.dart';
import '../features/levantamientos/models/levantamiento.dart';
import '../features/levantamientos/presentation/home_screen.dart';
import '../features/levantamientos/presentation/levantamiento_hub_screen.dart';

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
        path: '/levantamientos/:id',
        builder: (context, state) => LevantamientoHubScreen(
          levantamientoId: state.pathParameters['id']!,
          levantamiento: state.extra as Levantamiento?,
        ),
      ),
      GoRoute(
        path: '/levantamientos/:id/capturas',
        builder: (context, state) => CapturaScreen(
          levantamientoId: state.pathParameters['id']!,
          levantamiento: state.extra as Levantamiento?,
        ),
      ),
      GoRoute(
        path: '/levantamientos/:id/checklists',
        builder: (context, state) => ChecklistInstanciasListScreen(
          levantamientoId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/checklists/:id',
        builder: (context, state) => ChecklistFillScreen(instanciaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checklists/:id/datos',
        builder: (context, state) => ChecklistMetadataScreen(instanciaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checklist-plantillas',
        builder: (context, state) => const ChecklistPlantillasListScreen(),
      ),
      GoRoute(
        path: '/checklist-plantillas/:id',
        builder: (context, state) => ChecklistPlantillaBuilderScreen(
          plantillaId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/galeria/:id',
        builder: (context, state) => AlbumScreen(
          levantamientoId: state.pathParameters['id']!,
          titulo: state.extra as String?,
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
