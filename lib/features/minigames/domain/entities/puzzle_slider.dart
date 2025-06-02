class PuzzleSlider {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final String imageUrl;
  final int difficulty; // 3, 4, 5 para 3x3, 4x4, 5x5
  final String category;
  final bool isActive;

  const PuzzleSlider({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.difficulty,
    required this.category,
    this.isActive = true,
  });

  String getLocalizedTitle(String languageCode) {
    return title[languageCode] ?? title['es'] ?? 'Sin título';
  }

  String getLocalizedDescription(String languageCode) {
    return description[languageCode] ?? description['es'] ?? 'Sin descripción';
  }

  PuzzleSlider copyWith({
    String? id,
    Map<String, String>? title,
    Map<String, String>? description,
    String? imageUrl,
    int? difficulty,
    String? category,
    bool? isActive,
  }) {
    return PuzzleSlider(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PuzzleSlider && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PuzzleSlider(id: $id, difficulty: $difficulty)';
  }
}
