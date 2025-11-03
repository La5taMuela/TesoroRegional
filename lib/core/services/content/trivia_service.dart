import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tesoro_regional/features/minigames/data/models/trivia_question_dto.dart';

class TriviaService {
  static final TriviaService _instance = TriviaService._internal();
  factory TriviaService() => _instance;
  TriviaService._internal();

  final Map<String, List<TriviaQuestionDto>> _cache = {};
  final Map<String, List<String>> _categoriesCache = {};

  Future<List<TriviaQuestionDto>> loadTriviaQuestions(String languageCode) async {
    try {
      // Normalizar el código de idioma
      final normalizedLang = languageCode.toLowerCase() == 'es' ? 'es' : 'en';
      final path = 'assets/initial_content/trivia/$normalizedLang.json';

      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> questionsJson = jsonData['questions'];
      return questionsJson
          .map((q) => TriviaQuestionDto.fromJson(q))
          .toList();
    } catch (e) {
      print('Error loading trivia questions for $languageCode: $e');
      return [];
    }
  }

  Future<List<String>> getCategories(String languageCode) async {
    final cacheKey = 'categories_$languageCode';

    if (_categoriesCache.containsKey(cacheKey)) {
      return _categoriesCache[cacheKey]!;
    }

    try {
      final questions = await loadTriviaQuestions(languageCode);
      final categories = questions
          .map((q) => q.category)
          .toSet()
          .toList();

      _categoriesCache[cacheKey] = categories;
      return categories;
    } catch (e) {
      print('Error getting categories for $languageCode: $e');
      return [];
    }
  }

  Future<List<TriviaQuestionDto>> getQuestionsByCategory(
      String languageCode,
      String category
      ) async {
    final allQuestions = await loadTriviaQuestions(languageCode);
    return allQuestions
        .where((q) => q.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<List<TriviaQuestionDto>> getQuestionsByDifficulty(
      String languageCode,
      String difficulty
      ) async {
    final allQuestions = await loadTriviaQuestions(languageCode);
    return allQuestions
        .where((q) => q.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  void clearCache() {
    _cache.clear();
    _categoriesCache.clear();
  }
}
