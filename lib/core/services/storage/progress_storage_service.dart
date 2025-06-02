import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressStorageService {
  static const String _missionProgressKey = 'mission_progress';
  static const String _storyProgressKey = 'story_progress';
  static const String _triviaProgressKey = 'trivia_progress';

  // Misiones - Métodos para guardar y cargar progreso
  Future<void> saveMissionProgress(String missionId, List<bool> pointsCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = await _getMissionProgressMap();

      progressMap[missionId] = pointsCompleted;

      await prefs.setString(_missionProgressKey, json.encode(progressMap));
    } catch (e) {
      print('Error saving mission progress: $e');
    }
  }

  Future<List<bool>?> loadMissionProgress(String missionId) async {
    try {
      final progressMap = await _getMissionProgressMap();
      final progress = progressMap[missionId];

      if (progress != null) {
        return List<bool>.from(progress);
      }
      return null;
    } catch (e) {
      print('Error loading mission progress: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _getMissionProgressMap() async {
    final prefs = await SharedPreferences.getInstance();
    final progressString = prefs.getString(_missionProgressKey);

    if (progressString != null) {
      return Map<String, dynamic>.from(json.decode(progressString));
    }
    return {};
  }

  // Historias - Métodos para marcar como leídas
  Future<void> markStoryAsRead(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readStories = await getReadStories();

      if (!readStories.contains(storyId)) {
        readStories.add(storyId);
        await prefs.setStringList(_storyProgressKey, readStories);
      }
    } catch (e) {
      print('Error marking story as read: $e');
    }
  }

  Future<List<String>> getReadStories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_storyProgressKey) ?? [];
    } catch (e) {
      print('Error getting read stories: $e');
      return [];
    }
  }

  // Trivia - Métodos para guardar y cargar progreso
  Future<void> saveTriviaScore(String triviaId, int score, int totalQuestions, Duration timeTaken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'trivia_score_$triviaId';
      final scoreData = {
        'score': score,
        'totalQuestions': totalQuestions,
        'timeTaken': timeTaken.inSeconds,
        'completedAt': DateTime.now().toIso8601String(),
        'percentage': (score / totalQuestions * 100).round(),
      };
      await prefs.setString(key, json.encode(scoreData));

      // También guardar en la lista de trivias completadas
      await _addCompletedTrivia(triviaId);
    } catch (e) {
      print('Error saving trivia score: $e');
    }
  }

  Future<Map<String, dynamic>?> getTriviaScore(String triviaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'trivia_score_$triviaId';
      final scoreJson = prefs.getString(key);

      if (scoreJson != null) {
        return json.decode(scoreJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting trivia score: $e');
      return null;
    }
  }

  Future<List<String>> getCompletedTrivias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_triviaProgressKey) ?? [];
    } catch (e) {
      print('Error getting completed trivias: $e');
      return [];
    }
  }

  Future<void> _addCompletedTrivia(String triviaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = await getCompletedTrivias();

      if (!completed.contains(triviaId)) {
        completed.add(triviaId);
        await prefs.setStringList(_triviaProgressKey, completed);
      }
    } catch (e) {
      print('Error adding completed trivia: $e');
    }
  }

  Future<Map<String, dynamic>> getTriviaStats() async {
    try {
      final completed = await getCompletedTrivias();
      int totalScore = 0;
      int totalQuestions = 0;
      int totalTime = 0;

      for (String triviaId in completed) {
        final score = await getTriviaScore(triviaId);
        if (score != null) {
          totalScore += score['score'] as int;
          totalQuestions += score['totalQuestions'] as int;
          totalTime += score['timeTaken'] as int;
        }
      }

      return {
        'gamesPlayed': completed.length,
        'totalScore': totalScore,
        'totalQuestions': totalQuestions,
        'averageScore': totalQuestions > 0 ? (totalScore / totalQuestions * 100).round() : 0,
        'totalTime': totalTime,
        'averageTime': completed.isNotEmpty ? (totalTime / completed.length).round() : 0,
      };
    } catch (e) {
      print('Error getting trivia stats: $e');
      return {
        'gamesPlayed': 0,
        'totalScore': 0,
        'totalQuestions': 0,
        'averageScore': 0,
        'totalTime': 0,
        'averageTime': 0,
      };
    }
  }

  // Método para limpiar todo el progreso (para testing o reset)
  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_missionProgressKey);
    await prefs.remove(_storyProgressKey);
    await prefs.remove(_triviaProgressKey);
  }
}
