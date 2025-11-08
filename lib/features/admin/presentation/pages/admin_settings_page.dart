import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminSettingsPage extends ConsumerWidget {
  const AdminSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brownColor = Color(0xFF8B4513);
    const darkBrown = Color(0xFF654321);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: brownColor,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.security, color: brownColor),
              title: const Text('Seguridad'),
              subtitle: const Text('Gestionar permisos y roles'),
              onTap: () {},
            ),
            Divider(color: brownColor.withOpacity(0.2)),
            ListTile(
              leading: const Icon(Icons.notifications, color: brownColor),
              title: const Text('Notificaciones'),
              subtitle: const Text('Configurar alertas'),
              onTap: () {},
            ),
            Divider(color: brownColor.withOpacity(0.2)),
            ListTile(
              leading: const Icon(Icons.backup, color: brownColor),
              title: const Text('Respaldo'),
              subtitle: const Text('Descargar datos'),
              onTap: () {},
            ),
            Divider(color: brownColor.withOpacity(0.2)),
            ListTile(
              leading: const Icon(Icons.info, color: brownColor),
              title: const Text('Información'),
              subtitle: const Text('Versión y detalles'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
