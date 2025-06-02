import 'package:tesoro_regional/core/utils/typedefs.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/geo_position.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/language_localized.dart';

class CulturalPiece {
  final UniqueId id;
  final GeoPosition position;
  final PieceCategory category;
  final List<LanguageLocalized> descriptions;
  final int unlockThreshold;
  final DateTime? discoveredAt;
  final bool isUnlocked;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;

  const CulturalPiece({
    required this.id,
    required this.position,
    required this.category,
    required this.descriptions,
    required this.unlockThreshold,
    this.discoveredAt,
    required this.isUnlocked,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
  });

  String getLocalizedDescription(String languageCode) {
    try {
      return descriptions
          .firstWhere((desc) => desc.languageCode == languageCode)
          .text;
    } catch (e) {
      return descriptions.isNotEmpty ? descriptions.first.text : '';
    }
  }

  bool get hasMedia => imageUrl != null || audioUrl != null || videoUrl != null;
}
