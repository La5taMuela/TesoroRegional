import 'package:tesoro_regional/core/services/network/network_service.dart';
import 'package:tesoro_regional/features/puzzle/data/models/cultural_piece_dto.dart';
import 'package:tesoro_regional/features/puzzle/data/models/piece_category_dto.dart';
import 'package:tesoro_regional/features/puzzle/data/models/geo_position_dto.dart';
import 'package:tesoro_regional/features/puzzle/data/models/language_localized_dto.dart';

abstract class PuzzleRemoteDataSource {
  Future<List<CulturalPieceDto>> fetchPieces();
  Future<List<PieceCategoryDto>> fetchCategories();
  Future<List<PieceCategoryDto>> getCategories();
  Future<CulturalPieceDto?> fetchPieceByQrCode(String qrCode);
  Future<CulturalPieceDto?> getPieceByQrCode(String qrCode);
  Future<List<CulturalPieceDto>> fetchPiecesByLocation(double latitude, double longitude, double radiusInMeters);
  Future<CulturalPieceDto?> getPieceByLocation(double latitude, double longitude);
  Future<List<CulturalPieceDto>> getNearbyPieces(double latitude, double longitude, double radiusInMeters);
  Future<void> unlockPiece(String pieceId);
  Future<CulturalPieceDto?> getPieceByKeyword(String keyword);
}

class PuzzleRemoteDataSourceImpl implements PuzzleRemoteDataSource {
  final NetworkService _networkService;

  PuzzleRemoteDataSourceImpl(this._networkService);

  // Mock database of QR codes and their corresponding pieces
  final Map<String, String> _qrCodeToPieceId = {
    'Ñuble-plaza001': 'piece1',
    'Ñuble-mercado002': 'piece2',
    'Ñuble-museo003': 'piece3',
    'Ñuble-artesania004': 'piece4',
    'Ñuble-tradicion005': 'piece5',
  };

  // Mock data for pieces
  final List<CulturalPieceDto> _mockPieces = [
    const CulturalPieceDto(
      id: 'piece1',
      position: GeoPositionDto(
        latitude: -36.6062,
        longitude: -72.1025,
        address: 'Plaza de Armas, Chillán',
        placeName: 'Plaza de Armas',
      ),
      category: PieceCategoryDto(
        id: 'cat1',
        name: 'Monumentos',
        description: 'Monumentos históricos y arquitectónicos que narran la historia de Ñuble',
        iconPath: 'assets/icons/monuments.png',
        totalPieces: 10,
        collectedPieces: 1,
      ),
      descriptions: [
        LanguageLocalizedDto(
          languageCode: 'es',
          text: 'Plaza de Armas de Chillán, corazón histórico de la ciudad reconstruida tras el terremoto de 1939.',
        ),
        LanguageLocalizedDto(
          languageCode: 'en',
          text: 'Chillán\'s Main Square, historic heart of the city rebuilt after the 1939 earthquake.',
        ),
      ],
      unlockThreshold: 1,
      discoveredAt: null,
      isUnlocked: false,
      imageUrl: 'https://via.placeholder.com/400x200',
    ),
    const CulturalPieceDto(
      id: 'piece2',
      position: GeoPositionDto(
        latitude: -36.6082,
        longitude: -72.1045,
        address: 'Mercado de Chillán',
        placeName: 'Mercado',
      ),
      category: PieceCategoryDto(
        id: 'cat2',
        name: 'Gastronomía',
        description: 'Tradiciones culinarias y productos gastronómicos típicos de Ñuble',
        iconPath: 'assets/icons/food.png',
        totalPieces: 8,
        collectedPieces: 1,
      ),
      descriptions: [
        LanguageLocalizedDto(
          languageCode: 'es',
          text: 'Mercado de Chillán, centro gastronómico tradicional con productos locales y artesanías.',
        ),
        LanguageLocalizedDto(
          languageCode: 'en',
          text: 'Chillán Market, traditional gastronomic center with local products and crafts.',
        ),
      ],
      unlockThreshold: 1,
      discoveredAt: null,
      isUnlocked: false,
      imageUrl: 'https://via.placeholder.com/400x200',
    ),
    const CulturalPieceDto(
      id: 'piece3',
      position: GeoPositionDto(
        latitude: -36.6100,
        longitude: -72.1000,
        address: 'Museo de Ñuble',
        placeName: 'Museo',
      ),
      category: PieceCategoryDto(
        id: 'cat3',
        name: 'Historia',
        description: 'Lugares y sitios históricos que preservan la memoria de Ñuble',
        iconPath: 'assets/icons/history.png',
        totalPieces: 12,
        collectedPieces: 0,
      ),
      descriptions: [
        LanguageLocalizedDto(
          languageCode: 'es',
          text: 'Museo de Ñuble, guardián de la historia y cultura regional de la nueva región.',
        ),
        LanguageLocalizedDto(
          languageCode: 'en',
          text: 'Ñuble Museum, guardian of the regional history and culture of the new region.',
        ),
      ],
      unlockThreshold: 1,
      discoveredAt: null,
      isUnlocked: false,
      imageUrl: 'https://via.placeholder.com/400x200',
    ),
    const CulturalPieceDto(
      id: 'piece4',
      position: GeoPositionDto(
        latitude: -36.6120,
        longitude: -72.1080,
        address: 'Taller de Artesanía, Chillán',
        placeName: 'Taller de Artesanía',
      ),
      category: PieceCategoryDto(
        id: 'cat4',
        name: 'Artesanía',
        description: 'Artesanías tradicionales y técnicas ancestrales de la región de Ñuble',
        iconPath: 'assets/icons/crafts.png',
        totalPieces: 15,
        collectedPieces: 0,
      ),
      descriptions: [
        LanguageLocalizedDto(
          languageCode: 'es',
          text: 'Taller de artesanía tradicional donde se preservan las técnicas ancestrales de Ñuble.',
        ),
        LanguageLocalizedDto(
          languageCode: 'en',
          text: 'Traditional crafts workshop where ancestral techniques of Ñuble are preserved.',
        ),
      ],
      unlockThreshold: 1,
      discoveredAt: null,
      isUnlocked: false,
      imageUrl: 'https://via.placeholder.com/400x200',
    ),
    const CulturalPieceDto(
      id: 'piece5',
      position: GeoPositionDto(
        latitude: -36.6040,
        longitude: -72.1060,
        address: 'Casa de la Cultura, Chillán',
        placeName: 'Casa de la Cultura',
      ),
      category: PieceCategoryDto(
        id: 'cat5',
        name: 'Tradiciones',
        description: 'Costumbres, festividades y expresiones culturales tradicionales de Ñuble',
        iconPath: 'assets/icons/traditions.png',
        totalPieces: 20,
        collectedPieces: 0,
      ),
      descriptions: [
        LanguageLocalizedDto(
          languageCode: 'es',
          text: 'Casa de la Cultura, espacio dedicado a promover las tradiciones y expresiones culturales locales.',
        ),
        LanguageLocalizedDto(
          languageCode: 'en',
          text: 'Cultural House, space dedicated to promoting local traditions and cultural expressions.',
        ),
      ],
      unlockThreshold: 1,
      discoveredAt: null,
      isUnlocked: false,
      imageUrl: 'https://via.placeholder.com/400x200',
    ),
  ];

  final List<PieceCategoryDto> _mockCategories = [
    const PieceCategoryDto(
      id: 'cat1',
      name: 'Monumentos',
      description: 'Monumentos históricos y arquitectónicos que narran la historia de Ñuble',
      iconPath: 'assets/icons/monuments.png',
      totalPieces: 10,
      collectedPieces: 1,
    ),
    const PieceCategoryDto(
      id: 'cat2',
      name: 'Gastronomía',
      description: 'Tradiciones culinarias y productos gastronómicos típicos de Ñuble',
      iconPath: 'assets/icons/food.png',
      totalPieces: 8,
      collectedPieces: 1,
    ),
    const PieceCategoryDto(
      id: 'cat3',
      name: 'Historia',
      description: 'Lugares y sitios históricos que preservan la memoria de Ñuble',
      iconPath: 'assets/icons/history.png',
      totalPieces: 12,
      collectedPieces: 0,
    ),
    const PieceCategoryDto(
      id: 'cat4',
      name: 'Artesanía',
      description: 'Artesanías tradicionales y técnicas ancestrales de la región de Ñuble',
      iconPath: 'assets/icons/crafts.png',
      totalPieces: 15,
      collectedPieces: 0,
    ),
    const PieceCategoryDto(
      id: 'cat5',
      name: 'Tradiciones',
      description: 'Costumbres, festividades y expresiones culturales tradicionales de Ñuble',
      iconPath: 'assets/icons/traditions.png',
      totalPieces: 20,
      collectedPieces: 0,
    ),
  ];

  @override
  Future<List<CulturalPieceDto>> fetchPieces() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockPieces;
  }

  @override
  Future<List<PieceCategoryDto>> fetchCategories() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockCategories;
  }

  @override
  Future<List<PieceCategoryDto>> getCategories() async {
    return fetchCategories();
  }

  @override
  Future<CulturalPieceDto?> getPieceByKeyword(String keyword) async {
    try {
      // Simulamos una búsqueda por palabra clave
      await Future.delayed(const Duration(milliseconds: 500));

      // Normalizar la palabra clave (minúsculas, sin acentos)
      final normalizedKeyword = keyword.toLowerCase().trim();

      // Mapa expandido de palabras clave a IDs de piezas
      final keywordToPieceId = {
        'plaza': 'piece1',
        'mercado': 'piece2',
        'museo': 'piece3',
        'artesania': 'piece4',
        'artesanía': 'piece4', // Con acento
        'tradicion': 'piece5',
        'tradición': 'piece5', // Con acento
        'catedral': 'piece1', // Mapear a plaza por ahora
        'monumento': 'piece1', // Mapear a plaza por ahora
        'cultura': 'piece5', // Mapear a tradicion por ahora
        'gastronomia': 'piece2', // Mapear a mercado
        'gastronomía': 'piece2', // Con acento
        'historia': 'piece3', // Mapear a museo
        'monumentos': 'piece1', // Plural
      };

      // Buscar coincidencia exacta primero
      String? pieceId = keywordToPieceId[normalizedKeyword];

      // Si no hay coincidencia exacta, buscar coincidencias parciales
      if (pieceId == null) {
        for (final entry in keywordToPieceId.entries) {
          if (normalizedKeyword.contains(entry.key) || entry.key.contains(normalizedKeyword)) {
            pieceId = entry.value;
            break;
          }
        }
      }

      if (pieceId != null) {
        // Encontrar la pieza en los datos simulados
        final piece = _mockPieces.firstWhere(
              (p) => p.id == pieceId,
          orElse: () => throw Exception('Pieza no encontrada'),
        );

        return piece.copyWith(
          isUnlocked: true,
          discoveredAt: DateTime.now(),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CulturalPieceDto?> fetchPieceByQrCode(String qrCode) async {
    await Future.delayed(const Duration(seconds: 1));

    // Verificar si el código QR sigue el formato de Tesoro Regional
    if (!qrCode.startsWith('Ñuble-')) {
      return null;
    }

    // Extraer la palabra clave del código QR
    final keyword = qrCode.substring(6); // Remover "Ñuble-"
    final baseKeyword = keyword.replaceAll(RegExp(r'[A-Za-z0-9]{6}$'), ''); // Remover sufijo aleatorio

    // Buscar una pieza basada en la palabra clave
    CulturalPieceDto? matchedPiece;

    // Mapeo de palabras clave a piezas
    final keywordToPiece = {
      'plaza': _mockPieces.firstWhere((p) => p.id == 'piece1'),
      'mercado': _mockPieces.firstWhere((p) => p.id == 'piece2'),
      'museo': _mockPieces.firstWhere((p) => p.id == 'piece3'),
      'artesania': _mockPieces.firstWhere((p) => p.id == 'piece4'),
      'tradicion': _mockPieces.firstWhere((p) => p.id == 'piece5'),
      'catedral': _mockPieces.firstWhere((p) => p.id == 'piece1'), // Mapear a plaza por ahora
      'monumento': _mockPieces.firstWhere((p) => p.id == 'piece1'), // Mapear a plaza por ahora
      'cultura': _mockPieces.firstWhere((p) => p.id == 'piece5'), // Mapear a tradicion por ahora
    };

    // Buscar coincidencia exacta o parcial
    for (final entry in keywordToPiece.entries) {
      if (baseKeyword.toLowerCase().contains(entry.key) || entry.key.contains(baseKeyword.toLowerCase())) {
        matchedPiece = entry.value;
        break;
      }
    }

    if (matchedPiece != null) {
      // Retornar la pieza con estado desbloqueado y fecha de descubrimiento
      return matchedPiece.copyWith(
        isUnlocked: true,
        discoveredAt: DateTime.now(),
      );
    }

    return null;
  }

  @override
  Future<CulturalPieceDto?> getPieceByQrCode(String qrCode) async {
    return fetchPieceByQrCode(qrCode);
  }

  @override
  Future<List<CulturalPieceDto>> fetchPiecesByLocation(double latitude, double longitude, double radiusInMeters) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockPieces.where((piece) {
      final lat1 = piece.position.latitude;
      final lon1 = piece.position.longitude;
      final lat2 = latitude;
      final lon2 = longitude;

      final distance = ((lat2 - lat1) * (lat2 - lat1) + (lon2 - lon1) * (lon2 - lon1)) * 111000;
      return distance <= radiusInMeters;
    }).toList();
  }

  @override
  Future<CulturalPieceDto?> getPieceByLocation(double latitude, double longitude) async {
    final pieces = await fetchPiecesByLocation(latitude, longitude, 100);
    return pieces.isNotEmpty ? pieces.first : null;
  }

  @override
  Future<List<CulturalPieceDto>> getNearbyPieces(double latitude, double longitude, double radiusInMeters) async {
    return fetchPiecesByLocation(latitude, longitude, radiusInMeters);
  }

  @override
  Future<void> unlockPiece(String pieceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would make an API call to unlock the piece
  }
}
