/// Entidad para almacenar estadísticas del dashboard admin
class AdminStats {
  final int totalUsers;
  final int totalPosts;
  final DateTime lastUpdated;

  AdminStats({
    required this.totalUsers,
    required this.totalPosts,
    required this.lastUpdated,
  });

  AdminStats copyWith({
    int? totalUsers,
    int? totalPosts,
    DateTime? lastUpdated,
  }) {
    return AdminStats(
      totalUsers: totalUsers ?? this.totalUsers,
      totalPosts: totalPosts ?? this.totalPosts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}