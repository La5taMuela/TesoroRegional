import 'package:flutter/material.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/minigames_page.dart';

class MinigameCard extends StatelessWidget {
  final GameItem game;
  final bool isLargeScreen;

  const MinigameCard({
    super.key,
    required this.game,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: game.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                game.color.withOpacity(0.05),
              ],
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
                      color: game.color.withAlpha(30),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: game.color.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      game.icon,
                      size: isLargeScreen ? 20 : 18,
                      color: game.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      game.title,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isLargeScreen ? 12 : 8),
              Expanded(
                child: Text(
                  game.description,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
