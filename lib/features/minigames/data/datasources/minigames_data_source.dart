import 'package:tesoro_regional/features/minigames/data/models/trivia_question_dto.dart';
import 'package:tesoro_regional/core/services/content/trivia_service.dart';
import 'package:tesoro_regional/core/services/storage/progress_storage_service.dart';

abstract class MinigamesDataSource {
  Future<List<TriviaQuestionDto>> getTriviaQuestions({String? category, String? languageCode});
  Future<List<String>> getMemoryGameImages({String? category});
  Future<void> saveGameScore(String gameType, int score, int maxScore, Duration timeTaken);
  Future<List<Map<String, dynamic>>> getGameScores(String gameType);
}

class MinigamesDataSourceImpl implements MinigamesDataSource {
  final TriviaService _triviaService = TriviaService();
  final ProgressStorageService _progressService = ProgressStorageService();

  final List<String> _mockMemoryImages = [
    'https://example.com/images/plaza_chillan.jpg',
    'https://example.com/images/mercado_chillan.jpg',
    'https://example.com/images/catedral_chillan.jpg',
    'https://example.com/images/nevados_chillan.jpg',
    'https://example.com/images/longaniza_san_carlos.jpg',
    'https://example.com/images/ceramica_quinchamali.jpg',
    'https://example.com/images/mural_siqueiros.jpg',
    'https://example.com/images/termas_chillan.jpg',
  ];

  @override
  Future<List<TriviaQuestionDto>> getTriviaQuestions({String? category, String? languageCode}) async {
    try {
      final language = languageCode ?? 'es';

      if (category != null) {
        return await _triviaService.getQuestionsByCategory(language, category);
      }

      return await _triviaService.loadTriviaQuestions(language);
    } catch (e) {
      print('Error loading trivia questions: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getMemoryGameImages({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMemoryImages;
  }

  @override
  Future<void> saveGameScore(String gameType, int score, int maxScore, Duration timeTaken) async {
    try {
      if (gameType == 'trivia') {
        // Generar un ID único para esta sesión de trivia
        final triviaId = 'trivia_${DateTime.now().millisecondsSinceEpoch}';
        await _progressService.saveTriviaScore(triviaId, score, maxScore, timeTaken);
      }

      print('Guardando puntuación: $gameType - $score/$maxScore en ${timeTaken.inSeconds}s');
    } catch (e) {
      print('Error saving game score: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGameScores(String gameType) async {
    try {
      if (gameType == 'trivia') {
        final stats = await _progressService.getTriviaStats();
        final completed = await _progressService.getCompletedTrivias();

        List<Map<String, dynamic>> scores = [];
        for (String triviaId in completed) {
          final score = await _progressService.getTriviaScore(triviaId);
          if (score != null) {
            scores.add(score);
          }
        }

        return scores;
      }

      // Mock data para otros juegos
      return [
        {
          'score': 8,
          'maxScore': 10,
          'timeTaken': 120,
          'completedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'score': 6,
          'maxScore': 8,
          'timeTaken': 95,
          'completedAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
      ];
    } catch (e) {
      print('Error getting game scores: $e');
      return [];
    }
  }
}
