import 'package:riverpod/riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_stats.dart';

final adminRepositoryProvider = Provider<AdminRepositoryImpl>((ref) {
  return AdminRepositoryImpl();
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  print('[v0] adminStatsProvider - Obteniendo estadísticas');
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getAdminStats();
});

final usersCountProvider = FutureProvider<int>((ref) async {
  print('[v0] usersCountProvider - Contando usuarios');
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('users').count().get();
    final count = snapshot.count ?? 0;
    print('[v0] usersCountProvider - Total usuarios: $count');
    return count;
  } catch (e) {
    print('[v0] usersCountProvider - Error: $e');
    return 0;
  }
});

final postsCountProvider = FutureProvider<int>((ref) async {
  print('[v0] postsCountProvider - Contando posts');
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('posts').get();
    final count = snapshot.docs.length;
    print('[v0] postsCountProvider - Total posts: $count');
    return count;
  } catch (e) {
    print('[v0] postsCountProvider - Error: $e');
    return 0;
  }
});

final allUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  print('[v0] allUsersProvider - Obteniendo usuarios');
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('users').get();
    final users = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
    print('[v0] allUsersProvider - Usuarios obtenidos: ${users.length}');
    return users;
  } catch (e) {
    print('[v0] allUsersProvider - Error: $e');
    return [];
  }
});
