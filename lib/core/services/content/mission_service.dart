import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tesoro_regional/features/missions/domain/entities/mission.dart';

class MissionService {
  static const String _basePath = 'assets/initial_content';

  // Cache para evitar cargar múltiples veces
  static final Map<String, List<Mission>> _missionsCache = {};

  // Misiones por defecto en caso de error
  static final List<Mission> _defaultMissions = [
    Mission(
      id: '1',
      title: 'Explora el Centro de Chillán',
      city: 'Chillán',
      description: 'Descubre los lugares más emblemáticos del centro histórico',
      points: [
        MissionPoint(
          name: 'Plaza de Armas',
          description: 'Visita el corazón de la ciudad',
          isCompleted: false,
        ),
        MissionPoint(
          name: 'Catedral',
          description: 'Conoce la catedral reconstruida',
          isCompleted: false,
        ),
      ],
      reward: 'Insignia de Explorador',
      difficulty: 'Fácil',
      estimatedTime: '2-3 horas',
    ),
    Mission(
      id: '2',
      title: 'Sabores de San Carlos',
      city: 'San Carlos',
      description: 'Descubre la gastronomía tradicional',
      points: [
        MissionPoint(
          name: 'Longaniza Tradicional',
          description: 'Prueba la famosa longaniza sancarlina',
          isCompleted: false,
        ),
        MissionPoint(
          name: 'Mercado Local',
          description: 'Visita el mercado municipal',
          isCompleted: false,
        ),
      ],
      reward: 'Insignia Gastronómica',
      difficulty: 'Medio',
      estimatedTime: '3-4 horas',
    ),
  ];

  Future<List<Mission>> loadMissions(String languageCode) async {
    // Verificar cache primero
    final cacheKey = 'missions_$languageCode';
    if (_missionsCache.containsKey(cacheKey)) {
      return _missionsCache[cacheKey]!;
    }

    try {
      print('Intentando cargar misiones desde: $_basePath/missions/$languageCode.json');
      final String jsonString = await rootBundle.loadString(
          '$_basePath/missions/$languageCode.json'
      );
      print('JSON cargado correctamente: ${jsonString.substring(0, min(100, jsonString.length))}...');

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> missionsJson = jsonData['missions'];

      final missions = missionsJson.map((json) => Mission.fromJson(json)).toList();
      print('Misiones parseadas: ${missions.length}');

      // Guardar en cache
      _missionsCache[cacheKey] = missions;
      return missions;
    } catch (e) {
      print('Error loading missions for $languageCode: $e');

      // Intentar cargar español como fallback
      if (languageCode != 'es') {
        try {
          print('Intentando cargar misiones en español como fallback');
          return await loadMissions('es');
        } catch (e2) {
          print('Error loading Spanish fallback: $e2');
        }
      }

      // Retornar misiones por defecto
      print('Retornando misiones por defecto');
      return _defaultMissions;
    }
  }

  // Precargar contenido
  Future<void> preloadContent() async {
    try {
      print('Precargando contenido de misiones');
      await Future.wait([
        loadMissions('es'),
        loadMissions('en'),
      ]);
      print('Precarga completada');
    } catch (e) {
      print('Error preloading content: $e');
    }
  }

  // Limpiar cache si es necesario
  void clearCache() {
    _missionsCache.clear();
  }

  // Método para verificar si los archivos existen
  Future<bool> checkFilesExist() async {
    try {
      await rootBundle.load('$_basePath/missions/es.json');
      print('El archivo es.json existe');
      await rootBundle.load('$_basePath/missions/en.json');
      print('El archivo en.json existe');
      return true;
    } catch (e) {
      print('Error verificando archivos: $e');
      return false;
    }
  }
}

// Función auxiliar para evitar errores
int min(int a, int b) {
  return a < b ? a : b;
}
