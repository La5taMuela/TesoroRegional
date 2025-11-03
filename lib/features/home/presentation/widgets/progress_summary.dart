import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';
import 'package:tesoro_regional/core/services/storage/unified_pieces_storage.dart';

class ProgressSummary extends StatefulWidget {
  final double completionPercentage;
  final int collectedPieces;
  final int totalPieces;

  const ProgressSummary({
    super.key,
    required this.completionPercentage,
    required this.collectedPieces,
    required this.totalPieces,
  });

  @override
  State<ProgressSummary> createState() => _ProgressSummaryState();
}

class _ProgressSummaryState extends State<ProgressSummary> {
  final PiecesStorageService _piecesService = PiecesStorageService();
  final UnifiedPiecesStorage _unifiedStorage = UnifiedPiecesStorage.instance;
  Map<String, dynamic> _piecesStats = {};

  @override
  void initState() {
    super.initState();
    _loadPiecesData();
  }

  Future<void> _loadPiecesData() async {
    try {
      print('🔄 Loading pieces data for progress summary...');
      final stats = await _piecesService.getPiecesStats();
      print('📊 Progress stats loaded: $stats');

      if (mounted) {
        setState(() {
          _piecesStats = stats;
        });
      }
    } catch (e) {
      print('❌ Error loading pieces data: $e');
      if (mounted) {
        setState(() {
          _piecesStats = {
            'total': 0,
            'mapPieces': 0,
            'qrPieces': 0,
            'percentage': 0,
          };
        });
      }
    }
  }

  // Add a method to refresh data when needed
  Future<void> refreshData() async {
    await _loadPiecesData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change (e.g., when returning from map)
    _loadPiecesData();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).primaryColor,
                        size: isLargeScreen ? 28 : 24,
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu Progreso',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: isLargeScreen ? 6 : 4),
                          Text(
                            '${_piecesStats['total'] ?? 0}/6 piezas colectadas',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 16 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isLargeScreen ? 20 : 16),

                // Progress bars separadas para Mapa y QR
                _buildProgressSection('Mapa', _piecesStats['mapPieces'] ?? 0, 3, Colors.green, isLargeScreen),
                SizedBox(height: isLargeScreen ? 12 : 8),
                _buildProgressSection('QR Provincias', _piecesStats['qrPieces'] ?? 0, 3, Colors.purple, isLargeScreen),

                SizedBox(height: isLargeScreen ? 20 : 16),

                // Botón para ver piezas colectadas
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/collected-pieces');
                    },
                    icon: const Icon(Icons.collections),
                    label: const Text('Ver Piezas Colectadas'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isLargeScreen ? 16 : 12,
                        horizontal: isLargeScreen ? 24 : 16,
                      ),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                SizedBox(height: isLargeScreen ? 16 : 12),

                // Achievement badges
                if (isLargeScreen)
                  Row(
                    children: [
                      _buildAchievementBadge(
                        context,
                        Icons.explore,
                        'Explorador',
                        (_piecesStats['mapPieces'] ?? 0) >= 2,
                        isLargeScreen,
                      ),
                      const SizedBox(width: 12),
                      _buildAchievementBadge(
                        context,
                        Icons.qr_code,
                        'Cazador QR',
                        (_piecesStats['qrPieces'] ?? 0) >= 2,
                        isLargeScreen,
                      ),
                      const SizedBox(width: 12),
                      _buildAchievementBadge(
                        context,
                        Icons.emoji_events,
                        'Maestro',
                        (_piecesStats['total'] ?? 0) >= 6,
                        isLargeScreen,
                      ),
                    ],
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAchievementBadge(
                        context,
                        Icons.explore,
                        'Explorador',
                        (_piecesStats['mapPieces'] ?? 0) >= 2,
                        isLargeScreen,
                      ),
                      _buildAchievementBadge(
                        context,
                        Icons.qr_code,
                        'Cazador QR',
                        (_piecesStats['qrPieces'] ?? 0) >= 2,
                        isLargeScreen,
                      ),
                      _buildAchievementBadge(
                        context,
                        Icons.emoji_events,
                        'Maestro',
                        (_piecesStats['total'] ?? 0) >= 6,
                        isLargeScreen,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(String title, int current, int total, Color color, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            Text(
              '$current/$total',
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: isLargeScreen ? 8 : 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: isLargeScreen ? 8 : 6,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
      BuildContext context,
      IconData icon,
      String label,
      bool isUnlocked,
      bool isLargeScreen,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 12 : 8,
        vertical: isLargeScreen ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isLargeScreen ? 18 : 16,
            color: isUnlocked
                ? Theme.of(context).primaryColor
                : Colors.grey[400],
          ),
          SizedBox(width: isLargeScreen ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
