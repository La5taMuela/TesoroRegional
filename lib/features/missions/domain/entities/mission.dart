class Mission {
  final String id;
  final String title;
  final String city;
  final String description;
  final List<MissionPoint> points;
  final String reward;
  final String difficulty;
  final String estimatedTime;

  Mission({
    required this.id,
    required this.title,
    required this.city,
    required this.description,
    required this.points,
    required this.reward,
    required this.difficulty,
    required this.estimatedTime,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      title: json['title'] as String,
      city: json['city'] as String,
      description: json['description'] as String,
      points: (json['points'] as List<dynamic>)
          .map((e) => MissionPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      reward: json['reward'] as String,
      difficulty: json['difficulty'] as String,
      estimatedTime: json['estimatedTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'description': description,
      'points': points.map((e) => e.toJson()).toList(),
      'reward': reward,
      'difficulty': difficulty,
      'estimatedTime': estimatedTime,
    };
  }

  int get completedPoints => points.where((p) => p.isCompleted).length;
  double get progress => points.isEmpty ? 0 : completedPoints / points.length;
  bool get isCompleted => completedPoints == points.length;
}

class MissionPoint {
  final String name;
  final String description;
  bool isCompleted;

  MissionPoint({
    required this.name,
    required this.description,
    required this.isCompleted,
  });

  factory MissionPoint.fromJson(Map<String, dynamic> json) {
    return MissionPoint(
      name: json['name'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}
