import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/admin_stats_grid.dart';
import '../providers/admin_providers.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF8B4513);
    const accentColor = Color(0xFFD2B48C);
    const darkColor = Color(0xFF654321);
    const successColor = Color(0xFF4CAF50);
    const warningColor = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, darkColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(adminStatsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualizando estadísticas...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
            tooltip: 'Notificaciones',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('Mi Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Configuración'),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(firebaseAuthServiceProvider).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.1), accentColor.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido, Administrador',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.verified_user, size: 16, color: successColor),
                              const SizedBox(width: 6),
                              Text(
                                'Panel de control administrativo',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Stats Section Header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Estadísticas en Tiempo Real',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const AdminStatsGrid(),
              const SizedBox(height: 32),

              // Quick Actions Header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Acciones Rápidas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Grid of action cards
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  _ActionCard(
                    title: 'Estadísticas',
                    subtitle: 'Ver métricas detalladas',
                    icon: Icons.bar_chart_rounded,
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/admin/stats'),
                  ),
                  _ActionCard(
                    title: 'Usuarios',
                    subtitle: 'Gestionar usuarios',
                    icon: Icons.people_rounded,
                    gradient: LinearGradient(
                      colors: [successColor, successColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/admin/users'),
                  ),
                  _ActionCard(
                    title: 'Publicaciones',
                    subtitle: 'Explorar contenido',
                    icon: Icons.article_rounded,
                    gradient: LinearGradient(
                      colors: [warningColor, warningColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/admin/posts'),
                  ),
                  _ActionCard(
                    title: 'Nuevo Usuario',
                    subtitle: 'Crear cuenta',
                    icon: Icons.person_add_rounded,
                    gradient: LinearGradient(
                      colors: [darkColor, darkColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/admin/create-user'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(icon, size: 100, color: Colors.white),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 28, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}