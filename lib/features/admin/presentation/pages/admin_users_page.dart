import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_providers.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brownColor = Color(0xFF8B4513);
    const lightBrown = Color(0xFFD2B48C);
    final statsAsync = adminStatsProvider;
    final usersAsync = ref.watch(allUsersProvider);

    final stats = ref.watch(statsAsync);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: brownColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: stats.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
              data: (statsData) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: brownColor, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, size: 32, color: brownColor),
                      const SizedBox(width: 16),
                      Text(
                        'Total de Usuarios: ${statsData.totalUsers}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brownColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (users) {
                if (users.isEmpty) {
                  return const Center(child: Text('No hay usuarios'));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: brownColor.withOpacity(0.2), width: 1),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: brownColor.withOpacity(0.2),
                          child: const Icon(Icons.person, color: brownColor),
                        ),
                        title: Text(user['name'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(child: Text('Ver detalles')),
                            const PopupMenuItem(child: Text('Suspender')),
                            const PopupMenuItem(child: Text('Banear')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
