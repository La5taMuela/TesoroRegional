import 'package:tesoro_regional/features/minigames/domain/entities/puzzle_slider.dart';

class PuzzleSliderDto {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final String imageUrl;
  final int difficulty;
  final String category;
  final bool isActive;

  const PuzzleSliderDto({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.difficulty,
    required this.category,
    this.isActive = true,
  });

  factory PuzzleSliderDto.fromJson(Map<String, dynamic> json) {
    return PuzzleSliderDto(
      id: json['id'] as String,
      title: Map<String, String>.from(json['title'] as Map),
      description: Map<String, String>.from(json['description'] as Map),
      imageUrl: json['imageUrl'] as String,
      difficulty: json['difficulty'] as int,
      category: json['category'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'difficulty': difficulty,
      'category': category,
      'isActive': isActive,
    };
  }

  PuzzleSlider toDomain() {
    return PuzzleSlider(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      difficulty: difficulty,
      category: category,
      isActive: isActive,
    );
  }

  factory PuzzleSliderDto.fromDomain(PuzzleSlider entity) {
    return PuzzleSliderDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      difficulty: entity.difficulty,
      category: entity.category,
      isActive: entity.isActive,
    );
  }
}
