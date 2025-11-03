import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/auth/presentation/providers/auth_providers.dart';
import 'package:tesoro_regional/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:tesoro_regional/features/profile/presentation/providers/profile_providers.dart';

class ProfileMenu extends ConsumerWidget {
  const ProfileMenu({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      try {
        print('[v0] Iniciando cierre de sesión...');

        final authService = ref.read(firebaseAuthServiceProvider);
        await authService.signOut();
        print('[v0] Sesión cerrada en Firebase');

        ref.invalidate(profileNotifierProvider);
        ref.invalidate(authStateProvider);
        print('[v0] Estados invalidados');

        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          context.go('/profile'); // ProfileGuard mostrará el login automáticamente
          print('[v0] Navegando a /profile (login)');
        }
      } catch (e) {
        print('[v0] Error al cerrar sesión: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool obscurePassword = true;

    final authService = ref.read(firebaseAuthServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Eliminar cuenta')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Esta acción es permanente',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Se eliminarán todos tus datos de forma irreversible.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Se eliminarán:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 8),
                _buildDeleteItem('Tu cuenta de usuario'),
                _buildDeleteItem('Todos tus datos personales'),
                _buildDeleteItem('Todas tus fotos y archivos'),
                _buildDeleteItem('Todo tu contenido'),
                const SizedBox(height: 20),
                const Text(
                  'Confirma con tu contraseña:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa tu contraseña'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                setState(() {
                  isLoading = true;
                });

                try {
                  print('[v0] Reautenticando usuario...');
                  await authService.reauthenticateWithPassword(password);
                  print('[v0] Usuario reautenticado, procediendo a eliminar cuenta...');

                  await authService.deleteAccount();
                  print('[v0] Cuenta eliminada exitosamente');

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    context.go('/profile'); // ProfileGuard mostrará el login automáticamente
                  }

                  Future.delayed(const Duration(milliseconds: 500), () {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Tu cuenta ha sido eliminada'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                } catch (e) {
                  print('[v0] Error al eliminar cuenta: $e');
                  setState(() {
                    isLoading = false;
                  });

                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceAll('Exception: ', ''),
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Eliminar cuenta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.close, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (profile != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B4423), Color(0xFF8B5A3C)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFD4B5A0),
                  backgroundImage: profile.profileImageUrl != null &&
                      profile.profileImageUrl!.isNotEmpty
                      ? NetworkImage(profile.profileImageUrl!)
                      : null,
                  child: profile.profileImageUrl == null ||
                      profile.profileImageUrl!.isEmpty
                      ? const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.name} ${profile.lastName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (profile.alias != null && profile.alias!.isNotEmpty)
                        Text(
                          '@${profile.alias}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'PERFIL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.edit_rounded,
          title: 'Editar perfil',
          subtitle: 'Actualiza tu información',
          color: const Color(0xFF8B4513),
          onTap: () => _navigateToEditProfile(context),
        ),
        const Divider(height: 32),

        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'GENERAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.bookmark_rounded,
          title: 'Guardados',
          subtitle: 'Publicaciones guardadas',
          color: Colors.blue,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Próximamente')),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.settings_rounded,
          title: 'Configuración',
          subtitle: 'Preferencias y privacidad',
          color: Colors.grey.shade700,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Próximamente')),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.help_rounded,
          title: 'Ayuda',
          subtitle: 'Centro de ayuda y soporte',
          color: Colors.teal,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Próximamente')),
            );
          },
        ),
        const Divider(height: 32),

        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'CUENTA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.logout_rounded,
          title: 'Cerrar sesión',
          subtitle: 'Salir de tu cuenta',
          color: Colors.orange,
          onTap: () => _signOut(context, ref),
        ),
        _buildMenuItem(
          icon: Icons.delete_forever_rounded,
          title: 'Eliminar cuenta',
          subtitle: 'Acción permanente',
          color: Colors.red,
          onTap: () => _showDeleteAccountDialog(context, ref),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
