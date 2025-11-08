import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:tesoro_regional/features/admin/presentation/pages/admin_stats_page.dart';
import 'package:tesoro_regional/features/admin/presentation/pages/admin_users_page.dart';
import 'package:tesoro_regional/features/admin/presentation/pages/admin_settings_page.dart';
import 'package:tesoro_regional/features/admin/presentation/pages/admin_create_user_page.dart';
import 'package:tesoro_regional/features/auth/presentation/pages/login_page.dart';

/// Router exclusivo para administradores
class AdminAppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/admin',
    routes: [
      GoRoute(
        path: '/admin',
        name: 'admin_dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/stats',
        name: 'admin_stats',
        builder: (context, state) => const AdminStatsPage(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin_settings',
        builder: (context, state) => const AdminSettingsPage(),
      ),
      GoRoute(
        path: '/admin/create-user',
        name: 'admin_create_user',
        builder: (context, state) => const AdminCreateUserPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
