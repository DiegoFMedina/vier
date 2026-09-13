import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/flat_illustration.dart';
import '../../../theme/app_colors.dart';
import '../../auth/state/auth_models.dart';
import '../../auth/state/auth_provider.dart';
import '../models/levantamiento.dart';
import '../state/levantamientos_provider.dart';
import 'widgets/levantamiento_card.dart';
import 'widgets/nuevo_levantamiento_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    if (auth.status != AuthStatus.authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final levantamientosAsync = ref.watch(levantamientosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${auth.user?.nombre.split(' ').first ?? ''}',
                style: Theme.of(context).textTheme.headlineSmall),
            Text('Levantamientos en terreno', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        toolbarHeight: 72,
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _LevantamientosTab(
            query: _query,
            onQueryChanged: (v) => setState(() => _query = v),
            levantamientosAsync: levantamientosAsync,
          ),
          _PerfilTab(nombre: auth.user?.nombre, email: auth.user?.email, role: auth.user?.role),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => showNuevoLevantamientoSheet(context),
              backgroundColor: AppColors.violetPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _LevantamientosTab extends ConsumerWidget {
  const _LevantamientosTab({
    required this.query,
    required this.onQueryChanged,
    required this.levantamientosAsync,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;
  final AsyncValue<List<Levantamiento>> levantamientosAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(levantamientosProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            sliver: SliverToBoxAdapter(
              child: TextField(
                onChanged: onQueryChanged,
                decoration: const InputDecoration(
                  hintText: 'Buscar levantamiento o dirección',
                  prefixIcon: Icon(Icons.search, color: AppColors.violetSoft),
                ),
              ),
            ),
          ),
          levantamientosAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('No se pudo cargar la información.\n$err',
                      textAlign: TextAlign.center),
                ),
              ),
            ),
            data: (items) {
              final filtered = query.isEmpty
                  ? items
                  : items
                      .where((l) =>
                          l.titulo.toLowerCase().contains(query.toLowerCase()) ||
                          (l.direccion ?? '').toLowerCase().contains(query.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FlatIllustration(size: 160, variant: IllustrationVariant.empty),
                          const SizedBox(height: 20),
                          Text(
                            items.isEmpty
                                ? 'Aún no tienes levantamientos'
                                : 'Sin resultados para tu búsqueda',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Toca "Nuevo" para iniciar un levantamiento en terreno',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final levantamiento = filtered[index];
                    return LevantamientoCard(
                      levantamiento: levantamiento,
                      onTap: () => context.push('/levantamientos/${levantamiento.id}', extra: levantamiento),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PerfilTab extends ConsumerWidget {
  const _PerfilTab({this.nombre, this.email, this.role});

  final String? nombre;
  final String? email;
  final String? role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.violetSurface,
            child: Text(
              (nombre ?? '?').substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 28, color: AppColors.violetPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          Text(nombre ?? '', style: Theme.of(context).textTheme.titleLarge),
          Text(email ?? '', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(role ?? '', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fact_check_outlined, color: AppColors.violetPrimary),
            title: const Text('Plantillas de checklist'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/checklist-plantillas'),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: AppColors.fucsia),
            label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.fucsia)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.fucsia),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ],
      ),
    );
  }
}
