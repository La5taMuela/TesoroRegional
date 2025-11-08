import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/home/presentation/pages/home_page.dart';
import 'package:tesoro_regional/features/puzzle/presentation/pages/puzzle_page.dart';
import 'package:tesoro_regional/features/puzzle/presentation/pages/collected_pieces_page.dart';
import 'package:tesoro_regional/features/map/presentation/pages/map_page.dart';
import 'package:tesoro_regional/features/missions/presentation/pages/missions_page.dart';
import 'package:tesoro_regional/features/stories/presentation/pages/stories_page.dart';
import 'package:tesoro_regional/features/settings/presentation/pages/settings_page.dart';
import 'package:tesoro_regional/features/settings/presentation/pages/qr_generator_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/minigames_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/trivia_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/memory_game_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/puzzle_slider_page.dart';
import 'package:tesoro_regional/features/nuble_map/presentation/pages/nuble_map_page.dart';
import 'package:tesoro_regional/features/nuble_map/presentation/pages/province_detail_page.dart';
import 'package:tesoro_regional/features/nuble_map/presentation/pages/city_detail_page.dart';
import '../../features/admin/presentation/pages/admin_create_user_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/posts/presentation/pages/create_post_page.dart';
import '../../features/profile/presentation/widgets/profile_guard.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_stats_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_settings_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final userRole = ref.watch(userRoleProvider);

  return userRole.when(
    // Si el usuario es admin, muestra solo rutas de admin
    data: (role) {
      if (role == 'admin') {
        return _createAdminRouter();
      }
      // Si es usuario normal o no tiene rol, muestra rutas normales
      return _createUserRouter();
    },
    // Mientras carga, muestra rutas normales
    loading: () => _createUserRouter(),
    // Si hay error, muestra rutas normales
    error: (_, __) => _createUserRouter(),
  );
});

GoRouter _createAdminRouter() {
  return GoRouter(
    initialLocation: '/admin',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/stats',
        builder: (context, state) => const AdminStatsPage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const AdminSettingsPage(),
      ),
      GoRoute(
        path: '/admin/create-user',
        name: 'admin_create_user',
        builder: (context, state) => const AdminCreateUserPage(),
      ),
    ],
  );
}

GoRouter _createUserRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/puzzle',
        builder: (context, state) => const PuzzlePage(),
      ),
      GoRoute(
        path: '/collected-pieces',
        builder: (context, state) => const CollectedPiecesPage(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: '/missions',
        builder: (context, state) => const MissionsPage(),
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const StoriesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/qr-generator',
        builder: (context, state) => const QRGeneratorPage(),
      ),
      GoRoute(
        path: '/minigames',
        builder: (context, state) => const MinigamesPage(),
      ),
      GoRoute(
        path: '/trivia',
        builder: (context, state) => const TriviaPage(),
      ),
      GoRoute(
        path: '/memory-game',
        builder: (context, state) => const MemoryGamePage(),
      ),
      GoRoute(
        path: '/puzzle-slider',
        builder: (context, state) => const PuzzleSliderPage(),
      ),
      GoRoute(
        path: '/nuble-map',
        builder: (context, state) => const NubleMapPage(),
      ),
      GoRoute(
        path: '/province/:provinceId',
        builder: (context, state) {
          final provinceId = state.pathParameters['provinceId']!;
          return ProvinceDetailPage(provinceId: provinceId);
        },
      ),
      GoRoute(
        path: '/city/:cityId',
        builder: (context, state) {
          final cityId = state.pathParameters['cityId']!;
          return CityDetailPage(cityId: cityId);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileGuard(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}
