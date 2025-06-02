import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tesoro_regional/core/database/content_database.dart';

class ContentService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://your-api-url.com/api';

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> preloadInitialContent() async {
    try {
      // Load initial stories
      final storiesBundle = await rootBundle.loadString('assets/initial_content/stories_es.json');
      final storiesData = json.decode(storiesBundle) as Map<String, dynamic>;

      for (final storyData in storiesData['stories']) {
        final story = LocalizedContent(
          id: storyData['id'],
          title: Map<String, String>.from(storyData['title']),
          description: Map<String, String>.from(storyData['description']),
          content: Map<String, String>.from(storyData['content']),
          category: storyData['category'],
          lastUpdated: DateTime.parse(storyData['lastUpdated']),
          lastAccessed: DateTime.now(),
        );
        await ContentDatabase.saveStory(story);
      }

      // Load initial missions
      final missionsBundle = await rootBundle.loadString('assets/initial_content/missions_es.json');
      final missionsData = json.decode(missionsBundle) as Map<String, dynamic>;

      for (final missionData in missionsData['missions']) {
        final mission = LocalizedContent(
          id: missionData['id'],
          title: Map<String, String>.from(missionData['title']),
          description: Map<String, String>.from(missionData['description']),
          content: Map<String, String>.from(missionData['content']),
          category: missionData['category'],
          lastUpdated: DateTime.parse(missionData['lastUpdated']),
          lastAccessed: DateTime.now(),
        );
        await ContentDatabase.saveMission(mission);
      }
    } catch (e) {
      print('Error preloading initial content: $e');
    }
  }

  Future<List<LocalizedContent>> getStories() async {
    if (await hasInternetConnection()) {
      await _downloadNewStories();
    }
    return ContentDatabase.getStories();
  }

  Future<List<LocalizedContent>> getMissions() async {
    if (await hasInternetConnection()) {
      await _downloadNewMissions();
    }
    return ContentDatabase.getMissions();
  }

  Future<void> _downloadNewStories() async {
    try {
      final response = await _dio.get('$_baseUrl/stories');
      final data = response.data as Map<String, dynamic>;

      for (final storyData in data['stories']) {
        final story = LocalizedContent(
          id: storyData['id'],
          title: Map<String, String>.from(storyData['title']),
          description: Map<String, String>.from(storyData['description']),
          content: Map<String, String>.from(storyData['content']),
          category: storyData['category'],
          lastUpdated: DateTime.parse(storyData['lastUpdated']),
          lastAccessed: DateTime.now(),
        );

        // Only save if it's newer than local version
        final existingStory = ContentDatabase.storiesBox.get(story.id);
        if (existingStory == null || story.lastUpdated.isAfter(existingStory.lastUpdated)) {
          await ContentDatabase.saveStory(story);
        }
      }
    } catch (e) {
      print('Error downloading stories: $e');
    }
  }

  Future<void> _downloadNewMissions() async {
    try {
      final response = await _dio.get('$_baseUrl/missions');
      final data = response.data as Map<String, dynamic>;

      for (final missionData in data['missions']) {
        final mission = LocalizedContent(
          id: missionData['id'],
          title: Map<String, String>.from(missionData['title']),
          description: Map<String, String>.from(missionData['description']),
          content: Map<String, String>.from(missionData['content']),
          category: missionData['category'],
          lastUpdated: DateTime.parse(missionData['lastUpdated']),
          lastAccessed: DateTime.now(),
        );

        // Only save if it's newer than local version
        final existingMission = ContentDatabase.missionsBox.get(mission.id);
        if (existingMission == null || mission.lastUpdated.isAfter(existingMission.lastUpdated)) {
          await ContentDatabase.saveMission(mission);
        }
      }
    } catch (e) {
      print('Error downloading missions: $e');
    }
  }

  Future<void> markContentAsAccessed(String id, String type) async {
    await ContentDatabase.updateLastAccessed(id, type);
  }

  Future<void> cleanOldContent() async {
    await ContentDatabase.cleanOldContent();
  }
}
