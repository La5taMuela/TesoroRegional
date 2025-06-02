import 'package:flutter/material.dart';

class ModuleGrid extends StatelessWidget {
  final List<ModuleItem> modules;

  const ModuleGrid({
    super.key,
    required this.modules,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320, // Altura fija suficiente para mostrar ambas filas completas
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2, // Proporción cuadrada
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return _ModuleCard(
            title: module.title,
            icon: module.icon,
            color: module.color,
            onTap: module.onTap,
          );
        },
      ),
    );
  }
}

class ModuleItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ModuleItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
