import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brownColor = Color(0xFF8B4513);
    const lightBrown = Color(0xFFD2B48C);
    const darkBrown = Color(0xFF654321);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: brownColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(firebaseAuthServiceProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido, Administrador',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _NavigationCard(
                    title: 'Estadísticas',
                    icon: Icons.bar_chart,
                    color: brownColor,
                    onTap: () => context.push('/admin/stats'),
                  ),
                  _NavigationCard(
                    title: 'Usuarios',
                    icon: Icons.people,
                    color: lightBrown,
                    onTap: () => context.push('/admin/users'),
                  ),
                  _NavigationCard(
                    title: 'Ver Posts',
                    icon: Icons.article,
                    color: darkBrown,
                    onTap: () => context.push('/search'),
                  ),
                  _NavigationCard(
                    title: 'Crear Usuario',
                    icon: Icons.person_add,
                    color: brownColor,
                    onTap: () => context.push('/admin/create-user'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
