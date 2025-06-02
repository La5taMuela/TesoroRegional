class Story {
  final String id;
  final String title;
  final String city;
  final String description;
  final String content;
  final String imageAsset; // Cambio de imageUrl a imageAsset
  final String category;
  final String author;
  final DateTime publishDate;
  final int readingTime; // en minutos

  Story({
    required this.id,
    required this.title,
    required this.city,
    required this.description,
    required this.content,
    required this.imageAsset,
    required this.category,
    required this.author,
    required this.publishDate,
    required this.readingTime,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      title: json['title'] as String,
      city: json['city'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      imageAsset: json['imageAsset'] as String,
      category: json['category'] as String,
      author: json['author'] as String,
      publishDate: DateTime.parse(json['publishDate'] as String),
      readingTime: json['readingTime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'description': description,
      'content': content,
      'imageAsset': imageAsset,
      'category': category,
      'author': author,
      'publishDate': publishDate.toIso8601String(),
      'readingTime': readingTime,
    };
  }
}
