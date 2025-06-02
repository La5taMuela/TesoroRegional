import 'package:flutter/material.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class PieceInfoSheet extends StatelessWidget {
  final CulturalPiece piece;
  final VoidCallback? onUnlock;

  const PieceInfoSheet({
    super.key,
    required this.piece,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (piece.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      piece.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 16),

                // Category
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        piece.category.name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      piece.isUnlocked ? Icons.lock_open : Icons.lock,
                      size: 16,
                      color: piece.isUnlocked ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      piece.isUnlocked ? l10n.unlocked : l10n.locked,
                      style: TextStyle(
                        fontSize: 12,
                        color: piece.isUnlocked ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  piece.getLocalizedDescription(
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 24),

                // Unlock button
                if (!piece.isUnlocked && onUnlock != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onUnlock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.unlock),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
