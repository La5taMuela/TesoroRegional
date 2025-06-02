import 'package:tesoro_regional/core/utils/typedefs.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/data/models/geo_position_dto.dart';
import 'package:tesoro_regional/features/puzzle/data/models/piece_category_dto.dart';
import 'package:tesoro_regional/features/puzzle/data/models/language_localized_dto.dart';

class CulturalPieceDto {
  final String id;
  final GeoPositionDto position;
  final PieceCategoryDto category;
  final List<LanguageLocalizedDto> descriptions;
  final int unlockThreshold;
  final DateTime? discoveredAt;
  final bool isUnlocked;
  final String? imageUrl;

  const CulturalPieceDto({
    required this.id,
    required this.position,
    required this.category,
    required this.descriptions,
    required this.unlockThreshold,
    this.discoveredAt,
    required this.isUnlocked,
    this.imageUrl,
  });

  factory CulturalPieceDto.fromJson(Map<String, dynamic> json) {
    return CulturalPieceDto(
      id: json['id'] as String,
      position: GeoPositionDto.fromJson(json['position'] as Map<String, dynamic>),
      category: PieceCategoryDto.fromJson(json['category'] as Map<String, dynamic>),
      descriptions: (json['descriptions'] as List<dynamic>)
          .map((e) => LanguageLocalizedDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      unlockThreshold: json['unlockThreshold'] as int,
      discoveredAt: json['discoveredAt'] != null
          ? DateTime.parse(json['discoveredAt'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position.toJson(),
      'category': category.toJson(),
      'descriptions': descriptions.map((e) => e.toJson()).toList(),
      'unlockThreshold': unlockThreshold,
      'discoveredAt': discoveredAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
      'imageUrl': imageUrl,
    };
  }

  CulturalPieceDto copyWith({
    String? id,
    GeoPositionDto? position,
    PieceCategoryDto? category,
    List<LanguageLocalizedDto>? descriptions,
    int? unlockThreshold,
    DateTime? discoveredAt,
    bool? isUnlocked,
    String? imageUrl,
  }) {
    return CulturalPieceDto(
      id: id ?? this.id,
      position: position ?? this.position,
      category: category ?? this.category,
      descriptions: descriptions ?? this.descriptions,
      unlockThreshold: unlockThreshold ?? this.unlockThreshold,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Convert to domain entity
  CulturalPiece toDomain() {
    return CulturalPiece(
      id: UniqueId.fromString(id),
      position: position.toDomain(),
      category: category.toDomain(),
      descriptions: descriptions.map((e) => e.toDomain()).toList(),
      unlockThreshold: unlockThreshold,
      discoveredAt: discoveredAt,
      isUnlocked: isUnlocked,
      imageUrl: imageUrl,
    );
  }

  // Create from domain entity
  factory CulturalPieceDto.fromDomain(CulturalPiece piece) {
    return CulturalPieceDto(
      id: piece.id.value,
      position: GeoPositionDto.fromDomain(piece.position),
      category: PieceCategoryDto.fromDomain(piece.category),
      descriptions: piece.descriptions.map((e) => LanguageLocalizedDto.fromDomain(e)).toList(),
      unlockThreshold: piece.unlockThreshold,
      discoveredAt: piece.discoveredAt,
      isUnlocked: piece.isUnlocked,
      imageUrl: piece.imageUrl,
    );
  }
}
