import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';

class PieceCategoryDto {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int totalPieces;
  final int collectedPieces;

  const PieceCategoryDto({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.totalPieces,
    required this.collectedPieces,
  });

  factory PieceCategoryDto.fromJson(Map<String, dynamic> json) {
    return PieceCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      totalPieces: json['totalPieces'] as int,
      collectedPieces: json['collectedPieces'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'totalPieces': totalPieces,
      'collectedPieces': collectedPieces,
    };
  }

  PieceCategoryDto copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    int? totalPieces,
    int? collectedPieces,
  }) {
    return PieceCategoryDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      totalPieces: totalPieces ?? this.totalPieces,
      collectedPieces: collectedPieces ?? this.collectedPieces,
    );
  }

  // Convert to domain entity
  PieceCategory toDomain() {
    return PieceCategory(
      id: id,
      name: name,
      description: description,
      iconPath: iconPath,
      totalPieces: totalPieces,
      collectedPieces: collectedPieces,
    );
  }

  // Create from domain entity
  factory PieceCategoryDto.fromDomain(PieceCategory category) {
    return PieceCategoryDto(
      id: category.id,
      name: category.name,
      description: category.description,
      iconPath: category.iconPath,
      totalPieces: category.totalPieces,
      collectedPieces: category.collectedPieces,
    );
  }
}
