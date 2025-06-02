class MemoryCard {
  final String id;
  final String imageUrl;
  final String title;
  final String category;
  final bool isFlipped;
  final bool isMatched;

  const MemoryCard({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? category,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      category: category ?? this.category,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
