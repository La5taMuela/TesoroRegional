import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_stats.dart';

class AdminRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AdminStats> getAdminStats() async {
    try {
      // Get total users
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      print('[v0] AdminRepository - Total usuarios: $totalUsers');

      // Get total admins
      final adminsSnapshot = await _firestore.collection('admins').get();
      final totalAdmins = adminsSnapshot.docs.length;

      // Get all pieces
      final piecesSnapshot = await _firestore.collection('pieces').get();
      final totalPieces = piecesSnapshot.docs.length;

      // Get completed pieces (mapPieces + qrPieces)
      int completedPieces = 0;
      for (var doc in piecesSnapshot.docs) {
        final data = doc.data();
        if (data['mapPieces'] == true || data['qrPieces'] == true) {
          completedPieces++;
        }
      }

      // Calculate percentage
      final completionPercentage = totalPieces > 0
          ? (completedPieces / totalPieces) * 100
          : 0.0;

      // Get pending content count
      final pendingSnapshot = await _firestore
          .collection('content')
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingContent = pendingSnapshot.docs.length;

      return AdminStats(
        totalUsers: totalUsers + totalAdmins,
        activeUsers: totalUsers,
        totalPosts: 0, // Will be fetched separately by postsCountProvider
        pendingModeration: 0,
        engagementRate: 0.0,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error fetching admin stats: $e');
      return AdminStats(
        totalUsers: 0,
        activeUsers: 0,
        totalPosts: 0,
        pendingModeration: 0,
        engagementRate: 0.0,
        lastUpdated: DateTime.now(),
      );
    }
  }
}
