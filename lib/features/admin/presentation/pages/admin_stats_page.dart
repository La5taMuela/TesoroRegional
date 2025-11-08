import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_stats_grid.dart';

class AdminStatsPage extends ConsumerWidget {
  const AdminStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brownColor = Color(0xFF8B4513);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: brownColor,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estadísticas del Sistema',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF654321),
                ),
              ),
              const SizedBox(height: 24),
              const AdminStatsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
