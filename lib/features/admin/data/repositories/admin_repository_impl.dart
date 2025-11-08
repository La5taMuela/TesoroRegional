import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/admin_stats.dart';
import '../../../../core/database/firestore_config.dart';
import '../../../../core/services/firestore_service.dart'; // Nuevo import

class AdminRepositoryImpl {
  Future<AdminStats> getAdminStats() async {
    try {
      print('[AdminRepository] Iniciando obtención de estadísticas...');

      // Get total users from all collections usando el servicio centralizado
      final usersFuture = FirestoreService.users.get();
      final adminsFuture = FirestoreService.admins.get();
      final pymesFuture = FirestoreService.pymes.get();
      final empresasFuture = FirestoreService.empresas.get();
      final postsFuture = FirestoreService.posts.get();

      // Wait for all queries to complete
      final results = await Future.wait([
        usersFuture,
        adminsFuture,
        pymesFuture,
        empresasFuture,
        postsFuture,
      ]);

      final usersSnapshot = results[0];
      final adminsSnapshot = results[1];
      final pymesSnapshot = results[2];
      final empresasSnapshot = results[3];
      final postsSnapshot = results[4];

      final totalUsers = usersSnapshot.docs.length +
          adminsSnapshot.docs.length +
          pymesSnapshot.docs.length +
          empresasSnapshot.docs.length;

      final totalPosts = postsSnapshot.docs.length;

      print('[AdminRepository] Estadísticas obtenidas:');
      print('- Usuarios: $totalUsers');
      print('- Posts: $totalPosts');

      return AdminStats(
        totalUsers: totalUsers,
        totalPosts: totalPosts,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('[AdminRepository] ERROR obteniendo estadísticas: $e');
      return AdminStats(
        totalUsers: 0,
        totalPosts: 0,
        lastUpdated: DateTime.now(),
      );
    }
  }
}