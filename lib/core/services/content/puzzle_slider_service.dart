import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tesoro_regional/features/minigames/domain/entities/puzzle_slider.dart';
import 'package:tesoro_regional/features/minigames/data/models/puzzle_slider_dto.dart';

class PuzzleSliderService {
  static const String _basePath = 'assets/initial_content/puzzle_sliders';

  Future<List<PuzzleSlider>> getPuzzleSliders({
    String languageCode = 'es',
  }) async {
    try {
      final String jsonString = await rootBundle.loadString('$_basePath/$languageCode.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> puzzlesJson = jsonData['puzzleSliders'] as List<dynamic>;

      final List<PuzzleSlider> puzzles = puzzlesJson
          .map((json) => PuzzleSliderDto.fromJson(json as Map<String, dynamic>).toDomain())
          .where((puzzle) => puzzle.isActive)
          .toList();

      return puzzles;
    } catch (e) {
      // Fallback to Spanish if the requested language is not available
      if (languageCode != 'es') {
        return getPuzzleSliders(languageCode: 'es');
      }
      throw Exception('Error loading puzzle sliders: $e');
    }
  }

  Future<PuzzleSlider?> getPuzzleSliderById(String id, {String languageCode = 'es'}) async {
    try {
      final puzzles = await getPuzzleSliders(languageCode: languageCode);
      return puzzles.firstWhere((puzzle) => puzzle.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<PuzzleSlider>> getPuzzleSlidersByCategory(
      String category, {
        String languageCode = 'es',
      }) async {
    try {
      final puzzles = await getPuzzleSliders(languageCode: languageCode);
      return puzzles.where((puzzle) => puzzle.category == category).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PuzzleSlider>> getPuzzleSlidersByDifficulty(
      int difficulty, {
        String languageCode = 'es',
      }) async {
    try {
      final puzzles = await getPuzzleSliders(languageCode: languageCode);
      return puzzles.where((puzzle) => puzzle.difficulty == difficulty).toList();
    } catch (e) {
      return [];
    }
  }
}
