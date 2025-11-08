/// Entidad para almacenar estadísticas del dashboard admin
class AdminStats {
  final int totalUsers;
  final int activeUsers;
  final int totalPosts;
  final int pendingModeration;
  final double engagementRate;
  final DateTime lastUpdated;

  AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPosts,
    required this.pendingModeration,
    required this.engagementRate,
    required this.lastUpdated,
  });

  AdminStats copyWith({
    int? totalUsers,
    int? activeUsers,
    int? totalPosts,
    int? pendingModeration,
    double? engagementRate,
    DateTime? lastUpdated,
  }) {
    return AdminStats(
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      totalPosts: totalPosts ?? this.totalPosts,
      pendingModeration: pendingModeration ?? this.pendingModeration,
      engagementRate: engagementRate ?? this.engagementRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
