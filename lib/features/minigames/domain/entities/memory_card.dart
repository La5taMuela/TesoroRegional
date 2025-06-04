class MemoryCard {
  final String id;
  final String imageUrl;
  final String title;
  final String category;
  final bool isFlipped;
  final bool isMatched;
  final String? description;

  const MemoryCard({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    this.isFlipped = false,
    this.isMatched = false,
    this.description,
  });

  MemoryCard copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? category,
    bool? isFlipped,
    bool? isMatched,
    String? description,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      category: category ?? this.category,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'category': category,
      'description': description,
      'isMatched': isMatched, // Añadir estado de coincidencia
    };
  }

  factory MemoryCard.fromJson(Map<String, dynamic> json) {
    return MemoryCard(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
      isMatched: json['isMatched'] ?? false, // Recuperar estado de coincidencia
    );
  }
}