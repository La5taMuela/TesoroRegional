import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tesoro_regional/features/minigames/domain/entities/memory_card.dart';

class MemoryCardsService {
  static const String _basePath = 'assets/initial_content/memory_cards';

  Map<String, dynamic>? _cachedData;
  String? _cachedLanguage;

  Future<Map<String, dynamic>> _loadData(String language) async {
    if (_cachedData != null && _cachedLanguage == language) {
      return _cachedData!;
    }

    try {
      final String jsonString = await rootBundle.loadString('$_basePath/$language.json');
      _cachedData = json.decode(jsonString);
      _cachedLanguage = language;
      return _cachedData!;
    } catch (e) {
      print('Error loading memory cards data for $language: $e');
      // Fallback to Spanish if English fails
      if (language != 'es') {
        try {
          final String jsonString = await rootBundle.loadString('$_basePath/es.json');
          _cachedData = json.decode(jsonString);
          _cachedLanguage = 'es';
          return _cachedData!;
        } catch (e2) {
          print('Error loading Spanish fallback: $e2');
          // Return hardcoded categories as last resort
          return _getHardcodedCategories();
        }
      }
      // Return hardcoded categories as last resort
      return _getHardcodedCategories();
    }
  }

  Map<String, dynamic> _getHardcodedCategories() {
    return {
      "categories": [
        {
          "id": "historia",
          "name": "Historia",
          "description": "Sitios históricos importantes",
          "icon": "history_edu",
          "color": "purple",
          "cards": [
            {"id": "iglesia", "title": "Iglesia Histórica", "description": "Una de las iglesias más antiguas de la región"},
            {"id": "plaza", "title": "Plaza Principal", "description": "Centro histórico de la ciudad"},
            {"id": "museo", "title": "Museo Regional", "description": "Exhibe la historia y cultura de Ñuble"},
            {"id": "teatro", "title": "Teatro Municipal", "description": "Importante centro cultural de la ciudad"},
          ]
        },
        {
          "id": "gastronomia",
          "name": "Gastronomía",
          "description": "Platos típicos locales",
          "icon": "restaurant",
          "color": "orange",
          "cards": [
            {"id": "empanadas", "title": "Empanadas", "description": "Tradicionales empanadas chilenas"},
            {"id": "cazuela", "title": "Cazuela", "description": "Plato típico chileno"},
            {"id": "sopaipillas", "title": "Sopaipillas", "description": "Masa frita tradicional"},
            {"id": "chicha", "title": "Chicha", "description": "Bebida fermentada tradicional"},
          ]
        },
        {
          "id": "naturaleza",
          "name": "Naturaleza",
          "description": "Paisajes naturales",
          "icon": "nature",
          "color": "green",
          "cards": [
            {"id": "cerro", "title": "Cerro", "description": "Formación montañosa de la región"},
            {"id": "rio", "title": "Río", "description": "Principal río de la zona"},
            {"id": "parque", "title": "Parque", "description": "Área verde protegida"},
            {"id": "bosque", "title": "Bosque", "description": "Bosque nativo de la región"},
          ]
        }
      ]
    };
  }

  Future<List<MemoryCategory>> getCategories(String language) async {
    final data = await _loadData(language);
    final List<dynamic> categoriesJson = data['categories'] ?? [];

    return categoriesJson.map((categoryJson) => MemoryCategory.fromJson(categoryJson)).toList();
  }

  Future<List<MemoryCard>> getCardsForCategory(String categoryId, String language) async {
    final categories = await getCategories(language);
    final category = categories.firstWhere(
          (cat) => cat.id == categoryId,
      orElse: () => throw Exception('Category not found: $categoryId'),
    );

    return category.cards;
  }

  Future<List<MemoryCard>> getAllCards(String language) async {
    final categories = await getCategories(language);
    final List<MemoryCard> allCards = [];

    for (final category in categories) {
      allCards.addAll(category.cards);
    }

    return allCards;
  }
}

class MemoryCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<MemoryCard> cards;

  MemoryCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.cards,
  });

  factory MemoryCategory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cardsJson = json['cards'] ?? [];
    final cards = cardsJson.map((cardJson) => _createMemoryCardFromJson(cardJson, json['name'] ?? '')).toList();

    return MemoryCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'help',
      color: json['color'] ?? 'grey',
      cards: cards,
    );
  }

  static MemoryCard _createMemoryCardFromJson(Map<String, dynamic> json, String categoryName) {
    return MemoryCard(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      category: categoryName,
      description: json['description'],
    );
  }
}
