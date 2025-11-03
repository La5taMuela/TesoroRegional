import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/qr_scanner/domain/entities/qr_piece.dart';

class UnifiedPiecesStorage {
  static UnifiedPiecesStorage? _instance;
  static UnifiedPiecesStorage get instance => _instance ??= UnifiedPiecesStorage._();

  UnifiedPiecesStorage._();

  static const String _qrPiecesKey = 'collected_qr_pieces';
  static const String _mapPiecesKey = 'collected_map_pieces';

  // Datos predefinidos de las piezas disponibles con imágenes locales
  static const Map<String, Map<String, dynamic>> _availablePieces = {
    'itata_ITATA001': {
      'id': 'itata_ITATA001',
      'province': 'itata',
      'title': 'Provincia Vinícola',
      'code': 'ITATA001',
      'type': 'qr',
      'category': 'Provincias',
      'name': 'Itata',
      'description': 'Provincia de Itata, conocida por sus viñedos y tradición vitivinícola ancestral.',
      'color': '#9C27B0',
      'svgFile': 'itata.svg',
      'imageUrl': 'assets/images/puzzle_slider/Viñedos del Valle del Itata.jpg',
    },
    'punilla_PUNILLA001': {
      'id': 'punilla_PUNILLA001',
      'province': 'punilla',
      'title': 'Cordillera de los Andes',
      'code': 'PUNILLA001',
      'type': 'qr',
      'category': 'Provincias',
      'name': 'Punilla',
      'description': 'Provincia de Punilla, tierra de montañas y tradiciones cordilleranas.',
      'color': '#2196F3',
      'svgFile': 'punilla.svg',
      'imageUrl': 'assets/images/puzzle_slider/Nevados de Chillán.jpg',
    },
    'diguillin_DIGUILLIN001': {
      'id': 'diguillin_DIGUILLIN001',
      'province': 'diguillin',
      'title': 'Valle Central',
      'code': 'DIGUILLIN001',
      'type': 'qr',
      'category': 'Provincias',
      'name': 'Diguillín',
      'description': 'Provincia de Diguillín, corazón del valle central de Ñuble.',
      'color': '#4CAF50',
      'svgFile': 'diguillin.svg',
      'imageUrl': 'assets/images/puzzle_slider/Plaza de Armas de Chillán.jpg',
    },
  };

  // Guardar una pieza QR
  Future<bool> saveQRPiece(QRPiece piece) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Verificar si la pieza ya existe
      final existingPieces = await getCollectedQRPieces();
      if (existingPieces.any((p) => p.id == piece.id)) {
        print('⚠️ Piece already exists: ${piece.id}');
        return false; // Ya existe
      }

      // Obtener datos predefinidos para agregar imageUrl
      final predefinedData = _availablePieces[piece.id];
      final pieceWithImage = piece.copyWith(
        imageUrl: predefinedData?['imageUrl'],
      );

      // Agregar la nueva pieza
      existingPieces.add(pieceWithImage);

      // Convertir a JSON y guardar
      final piecesJson = existingPieces.map((p) => {
        'id': p.id,
        'province': p.province,
        'title': p.title,
        'code': p.code,
        'collectedAt': p.collectedAt.toIso8601String(),
        'isCollected': p.isCollected,
        'imageUrl': p.imageUrl,
      }).toList();

      final success = await prefs.setString(_qrPiecesKey, jsonEncode(piecesJson));

      if (success) {
        print('✅ QR Piece saved successfully: ${piece.id}');
      }

      return success;
    } catch (e) {
      print('❌ Error saving QR piece: $e');
      return false;
    }
  }

  // Método genérico para guardar cualquier tipo de pieza
  Future<bool> savePieceData(Map<String, dynamic> pieceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Verificar si la pieza ya existe
      final existingPieces = await getCollectedPiecesData();
      if (existingPieces.any((p) => p['id'] == pieceData['id'])) {
        print('⚠️ Piece already exists: ${pieceData['id']}');
        return false; // Ya existe
      }

      // Determinar el tipo de pieza y guardar apropiadamente
      final pieceType = pieceData['type'] ?? 'unknown';

      if (pieceType == 'qr') {
        // Para piezas QR, usar el sistema QR existente
        final qrPiece = QRPiece(
          id: pieceData['id'],
          province: pieceData['province'] ?? pieceData['name'] ?? '',
          title: pieceData['title'] ?? pieceData['name'] ?? '',
          code: pieceData['code'] ?? pieceData['id'],
          collectedAt: DateTime.parse(pieceData['collectedAt'] ?? DateTime.now().toIso8601String()),
          isCollected: pieceData['isCollected'] ?? true,
          imageUrl: pieceData['imageUrl'],
        );
        return await saveQRPiece(qrPiece);
      } else {
        // Para piezas del mapa y otros tipos, usar un sistema genérico
        final mapPiecesJson = prefs.getString(_mapPiecesKey);

        List<Map<String, dynamic>> mapPieces = [];
        if (mapPiecesJson != null && mapPiecesJson.isNotEmpty) {
          final List<dynamic> piecesList = jsonDecode(mapPiecesJson);
          mapPieces = piecesList.cast<Map<String, dynamic>>();
        }

        // Agregar la nueva pieza
        mapPieces.add({
          'id': pieceData['id'],
          'name': pieceData['name'],
          'description': pieceData['description'],
          'category': pieceData['category'],
          'type': pieceData['type'],
          'siteType': pieceData['siteType'],
          'color': pieceData['color'],
          'latitude': pieceData['latitude'],
          'longitude': pieceData['longitude'],
          'collectedAt': pieceData['collectedAt'] ?? DateTime.now().toIso8601String(),
          'isUnlocked': pieceData['isUnlocked'] ?? true,
          'imageUrl': pieceData['imageUrl'],
        });

        final success = await prefs.setString(_mapPiecesKey, jsonEncode(mapPieces));

        if (success) {
          print('✅ Map piece saved successfully: ${pieceData['id']}');
        }

        return success;
      }
    } catch (e) {
      print('❌ Error saving piece data: $e');
      return false;
    }
  }

  // Obtener todas las piezas QR coleccionadas
  Future<List<QRPiece>> getCollectedQRPieces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final piecesJson = prefs.getString(_qrPiecesKey);

      if (piecesJson == null || piecesJson.isEmpty) {
        return [];
      }

      final List<dynamic> piecesList = jsonDecode(piecesJson);
      return piecesList.map((json) => QRPiece(
        id: json['id'],
        province: json['province'],
        title: json['title'],
        code: json['code'],
        collectedAt: DateTime.parse(json['collectedAt']),
        isCollected: json['isCollected'] ?? true,
        imageUrl: json['imageUrl'],
      )).toList();
    } catch (e) {
      print('❌ Error loading QR pieces: $e');
      return [];
    }
  }

  // Obtener todas las piezas del mapa coleccionadas
  Future<List<Map<String, dynamic>>> getCollectedMapPieces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapPiecesJson = prefs.getString(_mapPiecesKey);

      if (mapPiecesJson == null || mapPiecesJson.isEmpty) {
        return [];
      }

      final List<dynamic> piecesList = jsonDecode(mapPiecesJson);
      return piecesList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error loading map pieces: $e');
      return [];
    }
  }

  // Verificar si una pieza está coleccionada (QR o Map)
  Future<bool> isPieceCollected(String pieceId) async {
    try {
      // Verificar en piezas QR
      final qrPieces = await getCollectedQRPieces();
      if (qrPieces.any((piece) => piece.id == pieceId)) {
        return true;
      }

      // Verificar en piezas del mapa
      final mapPieces = await getCollectedMapPieces();
      if (mapPieces.any((piece) => piece['id'] == pieceId)) {
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error checking if piece is collected: $e');
      return false;
    }
  }

  // Obtener datos de piezas coleccionadas para el puzzle (QR + Map pieces)
  Future<List<Map<String, dynamic>>> getCollectedPiecesData() async {
    try {
      final qrPieces = await getCollectedQRPieces();
      final mapPieces = await getCollectedMapPieces();

      List<Map<String, dynamic>> allPieces = [];

      // Agregar piezas QR
      allPieces.addAll(qrPieces.map((piece) {
        // Combinar datos de la pieza coleccionada con datos predefinidos
        final predefinedData = _availablePieces[piece.id] ?? {};

        return {
          'id': piece.id,
          'title': piece.title,
          'province': piece.province,
          'code': piece.code,
          'collectedAt': piece.collectedAt.toIso8601String(),
          'isCollected': piece.isCollected,
          'type': predefinedData['type'] ?? 'qr',
          'category': predefinedData['category'] ?? 'Provincias',
          'name': predefinedData['name'] ?? piece.province,
          'description': predefinedData['description'] ?? 'Pieza coleccionada',
          'color': predefinedData['color'] ?? '#9C27B0',
          'svgFile': predefinedData['svgFile'] ?? '',
          'imageUrl': piece.imageUrl ?? predefinedData['imageUrl'],
        };
      }));

      // Agregar piezas del mapa
      allPieces.addAll(mapPieces);

      return allPieces;
    } catch (e) {
      print('❌ Error getting collected pieces data: $e');
      return [];
    }
  }

  // Obtener estadísticas de progreso (QR + Map pieces)
  Future<Map<String, dynamic>> getPiecesStats() async {
    try {
      final qrPieces = await getCollectedQRPieces();
      final mapPieces = await getCollectedMapPieces();
      final totalAvailable = _availablePieces.length + 4; // 3 QR + 4 Map = 7 total
      final qrCollected = qrPieces.length;
      final mapCollected = mapPieces.length;
      final totalCollected = qrCollected + mapCollected;
      final percentage = totalAvailable > 0 ? (totalCollected / totalAvailable * 100).round() : 0;

      return {
        'qrPieces': qrCollected,
        'mapPieces': mapCollected,
        'totalPieces': totalCollected,
        'totalAvailable': totalAvailable,
        'percentage': percentage,
      };
    } catch (e) {
      print('❌ Error getting pieces stats: $e');
      return {
        'qrPieces': 0,
        'mapPieces': 0,
        'totalPieces': 0,
        'totalAvailable': 7, // 3 QR + 4 Map
        'percentage': 0,
      };
    }
  }

  // Obtener información de una pieza por código QR
  Map<String, dynamic>? getPieceByQRCode(String qrCode) {
    // Buscar en las piezas disponibles
    for (final piece in _availablePieces.values) {
      if (qrCode.contains(piece['code']) || qrCode.contains(piece['province'])) {
        return piece;
      }
    }
    return null;
  }

  // Limpiar todas las piezas (para testing)
  Future<bool> clearAllPieces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_qrPiecesKey);
      await prefs.remove(_mapPiecesKey);
      await prefs.remove('collected_map_pieces'); // Clear map pieces too
      print('✅ All pieces cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing pieces: $e');
      return false;
    }
  }

  // Obtener todas las piezas disponibles (para referencia)
  Map<String, Map<String, dynamic>> get availablePieces => _availablePieces;
}
