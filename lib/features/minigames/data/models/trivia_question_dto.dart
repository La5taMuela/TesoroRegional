import 'package:tesoro_regional/features/minigames/domain/entities/trivia_question.dart';

class TriviaQuestionDto {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String difficulty;
  final String explanation;
  final String? imageUrl;

  const TriviaQuestionDto({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.difficulty,
    required this.explanation,
    this.imageUrl,
  });

  factory TriviaQuestionDto.fromJson(Map<String, dynamic> json) {
    return TriviaQuestionDto(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      explanation: json['explanation'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'category': category,
      'difficulty': difficulty,
      'explanation': explanation,
      'imageUrl': imageUrl,
    };
  }

  TriviaQuestion toDomain() {
    return TriviaQuestion(
      id: id,
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      category: category,
      difficulty: difficulty,
      explanation: explanation,
      imageUrl: imageUrl,
    );
  }

  factory TriviaQuestionDto.fromDomain(TriviaQuestion question) {
    return TriviaQuestionDto(
      id: question.id,
      question: question.question,
      options: question.options,
      correctAnswerIndex: question.correctAnswerIndex,
      category: question.category,
      difficulty: question.difficulty,
      explanation: question.explanation,
      imageUrl: question.imageUrl,
    );
  }
}
