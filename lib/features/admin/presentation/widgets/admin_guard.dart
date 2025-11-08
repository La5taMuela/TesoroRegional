import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/auth/presentation/providers/auth_providers.dart';
import 'package:tesoro_regional/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:tesoro_regional/features/home/presentation/pages/home_page.dart';

class AdminGuard extends ConsumerWidget {
  const AdminGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      Future.microtask(() => context.go('/'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isAdminAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) {
        print('[v0] AdminGuard Error: $err');
        // Si hay error, redirigir a home
        Future.microtask(() => context.go('/'));
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      data: (isAdmin) {
        print('[v0] AdminGuard - isAdmin: $isAdmin');

        if (isAdmin) {
          return const AdminDashboardPage();
        }

        Future.microtask(() => context.go('/'));
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
