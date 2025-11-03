import 'package:tesoro_regional/core/utils/typedefs.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/data/models/piece_category_dto.dart';
import 'package:tesoro_regional/features/puzzle/data/models/language_localized_dto.dart';

class CulturalPieceDto {
  final String id;
  final String province;
  final String title;
  final String qrCode;
  final PieceCategoryDto category;
  final List<LanguageLocalizedDto> descriptions;
  final DateTime? discoveredAt;
  final bool isUnlocked;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;

  const CulturalPieceDto({
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

  factory CulturalPieceDto.fromJson(Map<String, dynamic> json) {
    return CulturalPieceDto(
      id: json['id'] as String,
      province: json['province'] as String,
      title: json['title'] as String,
      qrCode: json['qrCode'] as String,
      category: PieceCategoryDto.fromJson(json['category'] as Map<String, dynamic>),
      descriptions: (json['descriptions'] as List<dynamic>)
          .map((e) => LanguageLocalizedDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      discoveredAt: json['discoveredAt'] != null
          ? DateTime.parse(json['discoveredAt'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province': province,
      'title': title,
      'qrCode': qrCode,
      'category': category.toJson(),
      'descriptions': descriptions.map((e) => e.toJson()).toList(),
      'discoveredAt': discoveredAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
    };
  }

  CulturalPieceDto copyWith({
    String? id,
    String? province,
    String? title,
    String? qrCode,
    PieceCategoryDto? category,
    List<LanguageLocalizedDto>? descriptions,
    DateTime? discoveredAt,
    bool? isUnlocked,
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
  }) {
    return CulturalPieceDto(
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

  // Convert to domain entity
  CulturalPiece toDomain() {
    return CulturalPiece(
      id: UniqueId.fromString(id),
      province: province,
      title: title,
      qrCode: qrCode,
      category: category.toDomain(),
      descriptions: descriptions.map((e) => e.toDomain()).toList(),
      discoveredAt: discoveredAt,
      isUnlocked: isUnlocked,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      videoUrl: videoUrl,
    );
  }

  // Create from domain entity
  factory CulturalPieceDto.fromDomain(CulturalPiece piece) {
    return CulturalPieceDto(
      id: piece.id.value,
      province: piece.province,
      title: piece.title,
      qrCode: piece.qrCode,
      category: PieceCategoryDto.fromDomain(piece.category),
      descriptions: piece.descriptions.map((e) => LanguageLocalizedDto.fromDomain(e)).toList(),
      discoveredAt: piece.discoveredAt,
      isUnlocked: piece.isUnlocked,
      imageUrl: piece.imageUrl,
      audioUrl: piece.audioUrl,
      videoUrl: piece.videoUrl,
    );
  }
}
