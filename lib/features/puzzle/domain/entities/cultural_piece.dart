import 'package:tesoro_regional/core/utils/typedefs.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/language_localized.dart';

class CulturalPiece {
  final UniqueId id;
  final String province;
  final String title;
  final String qrCode;
  final PieceCategory category;
  final List<LanguageLocalized> descriptions;
  final DateTime? discoveredAt;
  final bool isUnlocked;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;

  const CulturalPiece({
    required this.id,
    required this.province,
    required this.title,
    required this.qrCode,
    required this.category,
    required this.descriptions,
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

  CulturalPiece copyWith({
    UniqueId? id,
    String? province,
    String? title,
    String? qrCode,
    PieceCategory? category,
    List<LanguageLocalized>? descriptions,
    DateTime? discoveredAt,
    bool? isUnlocked,
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
  }) {
    return CulturalPiece(
      id: id ?? this.id,
      province: province ?? this.province,
      title: title ?? this.title,
      qrCode: qrCode ?? this.qrCode,
      category: category ?? this.category,
      descriptions: descriptions ?? this.descriptions,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
