import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class PuzzlePieceCard extends ConsumerWidget {
  final CulturalPiece piece;
  final VoidCallback? onTap;

  const PuzzlePieceCard({
    super.key,
    required this.piece,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLanguage = Localizations.localeOf(context).languageCode;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: piece.imageUrl != null
                    ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    piece.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                )
                    : const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),

            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      piece.getLocalizedDescription(currentLanguage).split('.').first,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category
                    Text(
                      piece.category.name,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),

                    const Spacer(),

                    // Status
                    Row(
                      children: [
                        Icon(
                          piece.isUnlocked ? Icons.lock_open : Icons.lock,
                          size: 16,
                          color: piece.isUnlocked ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          piece.isUnlocked
                              ? (l10n?.unlocked ?? 'Unlocked')
                              : (l10n?.locked ?? 'Locked'),
                          style: TextStyle(
                            fontSize: 12,
                            color: piece.isUnlocked ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
