class GameScore {
  final String gameType;
  final int score;
  final int maxScore;
  final DateTime completedAt;
  final Duration timeTaken;
  final Map<String, dynamic> additionalData;

  const GameScore({
    required this.gameType,
    required this.score,
    required this.maxScore,
    required this.completedAt,
    required this.timeTaken,
    this.additionalData = const {},
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  bool get isPerfectScore => score == maxScore;

  String get grade {
    final percent = percentage;
    if (percent >= 90) return 'Excelente';
    if (percent >= 80) return 'Muy Bueno';
    if (percent >= 70) return 'Bueno';
    if (percent >= 60) return 'Regular';
    return 'Necesita Mejorar';
  }
}
