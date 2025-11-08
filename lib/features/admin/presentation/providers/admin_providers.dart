import 'package:riverpod/riverpod.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_stats.dart';
import '../../../../core/services/firestore_service.dart';

final adminRepositoryProvider = Provider<AdminRepositoryImpl>((ref) {
  return AdminRepositoryImpl();
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  print('[AdminProvider] Solicitando estadísticas...');
  final repository = ref.watch(adminRepositoryProvider);
  final stats = await repository.getAdminStats();
  print('[AdminProvider] Estadísticas recibidas: ${stats.totalUsers} usuarios, ${stats.totalPosts} posts');
  return stats;
});

final usersCountProvider = FutureProvider<int>((ref) async {
  try {
    final snapshot = await FirestoreService.users.get();
    return snapshot.docs.length;
  } catch (e) {
    return 0;
  }
});

final postsCountProvider = FutureProvider<int>((ref) async {
  try {
    final snapshot = await FirestoreService.posts.get();
    return snapshot.docs.length;
  } catch (e) {
    return 0;
  }
});

final allUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final snapshot = await FirestoreService.users.get();
    return snapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {'id': doc.id, ...data};
    })
        .toList();
  } catch (e) {
    return [];
  }
});