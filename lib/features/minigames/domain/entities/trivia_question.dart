class TriviaQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String difficulty;
  final String explanation;
  final String? imageUrl;

  const TriviaQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.difficulty,
    required this.explanation,
    this.imageUrl,
  });

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  String get correctAnswer => options[correctAnswerIndex];
}
