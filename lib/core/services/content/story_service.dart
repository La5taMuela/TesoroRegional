import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tesoro_regional/features/stories/domain/entities/story.dart';

class StoryService {
  static const String _basePath = 'assets/initial_content';

  // Cache para evitar cargar múltiples veces
  static final Map<String, List<Story>> _storiesCache = {};

  Future<List<Story>> loadStories(String languageCode) async {
    // Verificar cache primero
    final cacheKey = 'stories_$languageCode';
    if (_storiesCache.containsKey(cacheKey)) {
      return _storiesCache[cacheKey]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
          '$_basePath/stories/$languageCode.json'
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> storiesJson = jsonData['stories'];

      final stories = storiesJson.map((json) => Story.fromJson(json)).toList();

      // Guardar en cache
      _storiesCache[cacheKey] = stories;
      return stories;
    } catch (e) {
      print('Error loading stories for $languageCode: $e');

      // Intentar cargar español como fallback
      if (languageCode != 'es') {
        try {
          return await loadStories('es');
        } catch (e2) {
          print('Error loading Spanish stories fallback: $e2');
        }
      }

      // Retornar lista vacía si todo falla
      return [];
    }
  }

  // Obtener ciudades únicas de las historias
  Future<List<String>> getCities(String languageCode) async {
    final stories = await loadStories(languageCode);
    final cities = stories.map((story) => story.city).toSet().toList();
    cities.sort();
    return cities;
  }

  // Obtener categorías únicas
  Future<List<String>> getCategories(String languageCode) async {
    final stories = await loadStories(languageCode);
    final categories = stories.map((story) => story.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Precargar contenido
  Future<void> preloadContent() async {
    try {
      await Future.wait([
        loadStories('es'),
        loadStories('en'),
      ]);
    } catch (e) {
      print('Error preloading stories content: $e');
    }
  }

  // Limpiar cache
  void clearCache() {
    _storiesCache.clear();
  }
}
