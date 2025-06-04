import 'package:flutter/material.dart';

class ProgressSummary extends StatelessWidget {
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
                            '${completionPercentage.toStringAsFixed(1)}% completado',
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

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Piezas Culturales',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '$collectedPieces/$totalPieces',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isLargeScreen ? 12 : 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completionPercentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        minHeight: isLargeScreen ? 10 : 8,
                      ),
                    ),
                  ],
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
                        collectedPieces >= 5,
                        isLargeScreen,
                      ),
                      const SizedBox(width: 12),
                      _buildAchievementBadge(
                        context,
                        Icons.star,
                        'Coleccionista',
                        collectedPieces >= 10,
                        isLargeScreen,
                      ),
                      const SizedBox(width: 12),
                      _buildAchievementBadge(
                        context,
                        Icons.emoji_events,
                        'Maestro',
                        collectedPieces >= 20,
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
                        collectedPieces >= 5,
                        isLargeScreen,
                      ),
                      _buildAchievementBadge(
                        context,
                        Icons.star,
                        'Coleccionista',
                        collectedPieces >= 10,
                        isLargeScreen,
                      ),
                      _buildAchievementBadge(
                        context,
                        Icons.emoji_events,
                        'Maestro',
                        collectedPieces >= 20,
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
