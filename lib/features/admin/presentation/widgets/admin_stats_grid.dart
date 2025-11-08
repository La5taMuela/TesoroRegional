import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';

class AdminStatsGrid extends ConsumerWidget {
  const AdminStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brownColor = Color(0xFF8B4513);
    const lightBrown = Color(0xFFD2B48C);

    final statsAsync = ref.watch(adminStatsProvider);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          title: 'Usuarios Totales',
          value: statsAsync.maybeWhen(
            data: (stats) => stats.totalUsers.toString(),
            orElse: () => '0',
          ),
          icon: Icons.people,
          color: brownColor,
          isLoading: statsAsync.isLoading,
        ),
        _StatCard(
          title: 'Posts Totales',
          value: statsAsync.maybeWhen(
            data: (stats) => stats.totalPosts.toString(),
            orElse: () => '0',
          ),
          icon: Icons.article,
          color: brownColor,
          isLoading: statsAsync.isLoading,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            isLoading
                ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
                : Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}