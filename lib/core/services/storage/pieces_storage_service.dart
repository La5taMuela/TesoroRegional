import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/qr_scanner/domain/entities/qr_piece.dart';
import 'unified_pieces_storage.dart';

class PiecesStorageService {
  static const String _collectedPiecesKey = 'collected_pieces';
  static const String _provincePiecesKey = 'province_pieces';

  // Use unified storage as the primary data source
  final UnifiedPiecesStorage _unifiedStorage = UnifiedPiecesStorage.instance;

  // Province pieces data
  final Map<String, Map<String, dynamic>> _provincePieces = {
    'Itata': {
      'id': 'province_itata',
      'name': 'Provincia de Itata',
      'description': 'Provincia ubicada en la región de Ñuble, conocida por sus viñedos y tradiciones rurales.',
      'category': 'Provincias',
      'qrCode': 'Ñuble-Itata',
      'imageUrl': 'assets/images/puzzle_slider/Viñedos del Valle del Itata.jpg',
      'isUnlocked': false,
    },
    'Diguillín': {
      'id': 'province_diguillin',
      'name': 'Provincia de Diguillín',
      'description': 'Provincia central de Ñuble, donde se encuentra la capital regional Chillán.',
      'category': 'Provincias',
      'qrCode': 'Ñuble-Diguillin',
      'imageUrl': 'assets/images/puzzle_slider/Plaza de Armas de Chillán.jpg',
      'isUnlocked': false,
    },
    'Punilla': {
      'id': 'province_punilla',
      'name': 'Provincia de Punilla',
      'description': 'Provincia montañosa de Ñuble, famosa por sus termas y paisajes cordilleranos.',
      'category': 'Provincias',
      'qrCode': 'Ñuble-Punilla',
      'imageUrl': 'assets/images/puzzle_slider/Nevados de Chillán.jpg',
      'isUnlocked': false,
    },
  };

  // Definición de las 7 piezas (actualizada para incluir las 4 del mapa + 3 QR con imágenes)
  static const List<Map<String, dynamic>> allPieces = [
    // Piezas del mapa (4)
    {
      'id': 'map_plaza_chillan',
      'name': 'Plaza de Armas de Chillán',
      'type': 'map',
      'siteType': 'plaza',
      'color': '#4CAF50',
      'description': 'Centro histórico de Chillán, punto de encuentro cultural y social.',
      'lat': -36.60668,
      'lng': -72.10332,
      'imageUrl': 'assets/images/puzzle_slider/Plaza de Armas de Chillán.jpg',
    },
    {
      'id': 'map_mercado_chillan',
      'name': 'Mercado de Chillán',
      'type': 'map',
      'siteType': 'market',
      'color': '#2196F3',
      'description': 'Mercado tradicional de la región, famoso por su gastronomía y artesanía local.',
      'lat': -36.610434,
      'lng': -72.101293,
      'imageUrl': 'assets/images/puzzle_slider/Mercado de Chillán.jpg',
    },
    {
      'id': 'map_catedral_chillan',
      'name': 'Catedral de Chillán',
      'type': 'map',
      'siteType': 'religious',
      'color': '#FF9800',
      'description': 'Patrimonio religioso de Chillán, reconstruida después del terremoto de 1939.',
      'lat': -36.606812,
      'lng': -72.102354,
      'imageUrl': 'assets/images/puzzle_slider/Catedral de San Bartolomé.jpg',
    },
    {
      'id': 'map_inacap_chillan',
      'name': 'Inacap Chillán',
      'type': 'map',
      'siteType': 'educational',
      'color': '#9C27B0',
      'description': 'Instituto profesional ubicado en Chillán.',
      'lat': -36.593860,
      'lng': -72.103804,
      'imageUrl': '/placeholder.svg?height=200&width=300',
    },
    // Piezas QR (3) - Provincias con imágenes
    {
      'id': 'qr_provincia_itata',
      'name': 'Provincia de Itata',
      'type': 'qr',
      'svgFile': 'itata.svg',
      'color': '#9C27B0',
      'description': 'Provincia famosa por sus viñedos y tradición vitivinícola ancestral.',
      'qrCode': 'PROVINCIA_ITATA_2024',
      'imageUrl': 'assets/images/puzzle_slider/Viñedos del Valle del Itata.jpg',
    },
    {
      'id': 'qr_provincia_diguillin',
      'name': 'Provincia de Diguillín',
      'type': 'qr',
      'svgFile': 'diguillin.svg',
      'color': '#E91E63',
      'description': 'Provincia que alberga la capital regional Chillán y las Termas de Chillán.',
      'qrCode': 'PROVINCIA_DIGUILLIN_2024',
      'imageUrl': 'assets/images/puzzle_slider/Termas de Chillán.jpg',
    },
    {
      'id': 'qr_provincia_punilla',
      'name': 'Provincia de Punilla',
      'type': 'qr',
      'svgFile': 'punilla.svg',
      'color': '#FF5722',
      'description': 'Provincia con importantes recursos hídricos y tradiciones campesinas.',
      'qrCode': 'PROVINCIA_PUNILLA_2024',
      'imageUrl': 'assets/images/puzzle_slider/Nevados de Chillán.jpg',
    },
  ];

  // Método para guardar una pieza QR - delegado al unified storage
  Future<bool> savePiece(QRPiece piece) async {
    try {
      return await _unifiedStorage.saveQRPiece(piece);
    } catch (e) {
      print('❌ Error saving piece: $e');
      return false;
    }
  }

  // Obtener piezas colectadas - desde unified storage
  Future<List<String>> getCollectedPieces() async {
    try {
      final collectedPiecesData = await _unifiedStorage.getCollectedPiecesData();
      return collectedPiecesData.map((piece) => piece['id'].toString()).toList();
    } catch (e) {
      print('❌ Error getting collected pieces: $e');
      return [];
    }
  }

  // Obtener piezas colectadas detalladas - desde unified storage
  Future<List<Map<String, dynamic>>> getCollectedPiecesDetailed() async {
    try {
      return await _unifiedStorage.getCollectedPiecesData();
    } catch (e) {
      print('❌ Error getting detailed pieces: $e');
      return [];
    }
  }

  Future<bool> collectPiece(String pieceId) async {
    try {
      // Buscar la pieza en allPieces para obtener información completa
      final pieceInfo = allPieces.firstWhere(
            (piece) => piece['id'] == pieceId,
        orElse: () => <String, dynamic>{},
      );

      if (pieceInfo.isEmpty) {
        print('❌ Piece not found: $pieceId');
        return false;
      }

      // Crear datos completos de la pieza
      final pieceData = {
        'id': pieceId,
        'name': pieceInfo['name'] ?? 'Pieza Cultural',
        'description': pieceInfo['description'] ?? 'Una pieza cultural de la región de Ñuble.',
        'category': pieceInfo['type'] == 'map' ? 'Sitios Culturales' : 'Provincias',
        'type': pieceInfo['type'] ?? 'map',
        'siteType': pieceInfo['siteType'],
        'color': pieceInfo['color'],
        'latitude': pieceInfo['lat'],
        'longitude': pieceInfo['lng'],
        'collectedAt': DateTime.now().toIso8601String(),
        'isUnlocked': true,
        'imageUrl': pieceInfo['imageUrl'], // Incluir imageUrl
      };

      // Guardar en el sistema unificado usando savePieceData
      return await _unifiedStorage.savePieceData(pieceData);
    } catch (e) {
      print('❌ Error collecting piece: $e');
      return false;
    }
  }

  Future<bool> collectProvincePiece(String provinceName) async {
    final prefs = await SharedPreferences.getInstance();
    final provincePieces = prefs.getStringList(_provincePiecesKey) ?? [];

    // Check if province is already collected
    for (String pieceJson in provincePieces) {
      try {
        final piece = json.decode(pieceJson);
        if (piece['name'].contains(provinceName)) {
          return false; // Already collected
        }
      } catch (e) {
        print('Error checking province piece: $e');
      }
    }

    // Get province data
    final provinceData = _provincePieces[provinceName];
    if (provinceData == null) return false;

    // Mark as collected
    final collectedProvince = Map<String, dynamic>.from(provinceData);
    collectedProvince['isUnlocked'] = true;
    collectedProvince['collectedAt'] = DateTime.now().toIso8601String();

    provincePieces.add(json.encode(collectedProvince));
    await prefs.setStringList(_provincePiecesKey, provincePieces);

    return true; // New province collected
  }

  // Verificar si una pieza está colectada - desde unified storage
  Future<bool> isPieceCollected(String pieceId) async {
    try {
      return await _unifiedStorage.isPieceCollected(pieceId);
    } catch (e) {
      print('❌ Error checking if piece is collected: $e');
      return false;
    }
  }

  // Obtener estadísticas - desde unified storage
  Future<Map<String, dynamic>> getPiecesStats() async {
    try {
      final stats = await _unifiedStorage.getPiecesStats();
      print('📊 Stats from unified storage: $stats');

      return {
        'total': stats['totalPieces'] ?? 0,
        'mapPieces': stats['mapPieces'] ?? 0,
        'qrPieces': stats['qrPieces'] ?? 0,
        'percentage': stats['percentage'] ?? 0,
      };
    } catch (e) {
      print('❌ Error getting pieces stats: $e');
      return {
        'total': 0,
        'mapPieces': 0,
        'qrPieces': 0,
        'percentage': 0,
      };
    }
  }

  Map<String, dynamic>? getPieceById(String pieceId) {
    try {
      return allPieces.firstWhere((piece) => piece['id'] == pieceId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? getPieceByQRCode(String qrCode) {
    return _unifiedStorage.getPieceByQRCode(qrCode);
  }

  List<Map<String, dynamic>> getMapPieces() {
    return allPieces.where((piece) => piece['type'] == 'map').toList();
  }

  List<Map<String, dynamic>> getQRPieces() {
    return allPieces.where((piece) => piece['type'] == 'qr').toList();
  }

  Future<void> clearAllPieces() async {
    await _unifiedStorage.clearAllPieces();

    // Also clear legacy SharedPreferences data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_collectedPiecesKey);
    await prefs.remove(_provincePiecesKey);
  }

  Future<int> getCollectedCount() async {
    try {
      final pieces = await getCollectedPiecesDetailed();
      return pieces.length;
    } catch (e) {
      print('❌ Error getting collected count: $e');
      return 0;
    }
  }

  Future<double> getCompletionPercentage() async {
    try {
      final stats = await getPiecesStats();
      return (stats['percentage'] ?? 0).toDouble();
    } catch (e) {
      print('❌ Error getting completion percentage: $e');
      return 0.0;
    }
  }
}
