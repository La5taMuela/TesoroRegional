import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/features/puzzle/presentation/state/puzzle_state.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/language_localized.dart';
import 'package:tesoro_regional/core/services/storage/unified_pieces_storage.dart';
import 'package:tesoro_regional/core/utils/typedefs.dart';

class PuzzleNotifier extends StateNotifier<PuzzleState> {
  final UnifiedPiecesStorage _storage = UnifiedPiecesStorage.instance;

  PuzzleNotifier() : super(const PuzzleInitial()) {
    loadPuzzleData();
  }

  Future<void> loadPuzzleData() async {
    state = const PuzzleLoading();

    try {
      print('🔄 Loading puzzle data from unified storage...');

      // Get collected pieces from unified storage
      final collectedPiecesData = await _storage.getCollectedPiecesData();
      final stats = await _storage.getPiecesStats();

      print('📊 Raw pieces data: $collectedPiecesData');
      print('📊 Stats: $stats');

      // Convert to CulturalPiece entities
      final List<CulturalPiece> collectedPieces = collectedPiecesData.map<CulturalPiece>((pieceData) {
        try {
          final pieceId = pieceData['id']?.toString() ?? '';
          print('🔧 Processing piece with ID: $pieceId');

          return CulturalPiece(
            id: UniqueId.fromString(pieceId),
            title: pieceData['title']?.toString() ?? '',
            province: pieceData['province']?.toString() ?? '',
            qrCode: pieceData['code']?.toString() ?? '',
            category: PieceCategory(
              id: 'provincias',
              name: 'Provincias',
              description: 'Provincias de la Región de Ñuble',
              iconPath: '',
              totalPieces: 3,
              collectedPieces: stats['qrPieces'] ?? 0,
            ),
            descriptions: [
              LanguageLocalized(
                languageCode: 'es',
                text: pieceData['description']?.toString() ?? 'Pieza coleccionada de ${pieceData['province']}',
              ),
            ],
            imageUrl: null,
            isUnlocked: true,
            discoveredAt: pieceData['collectedAt'] != null
                ? DateTime.tryParse(pieceData['collectedAt'].toString()) ?? DateTime.now()
                : DateTime.now(),
          );
        } catch (e) {
          print('❌ Error processing piece data: $pieceData, error: $e');
          rethrow;
        }
      }).toList();

      // Create default categories
      final categories = [
        PieceCategory(
          id: 'provincias',
          name: 'Provincias',
          description: 'Provincias de la Región de Ñuble',
          iconPath: '',
          totalPieces: 3,
          collectedPieces: stats['qrPieces'] ?? 0,
        ),
        PieceCategory(
          id: 'sitios',
          name: 'Sitios Culturales',
          description: 'Lugares de interés cultural',
          iconPath: '',
          totalPieces: 3,
          collectedPieces: stats['mapPieces'] ?? 0,
        ),
      ];

      final completionPercentage = (stats['percentage'] ?? 0).toDouble();

      state = PuzzleLoaded(
        categories: categories,
        collectedPieces: collectedPieces,
        completionPercentage: completionPercentage,
      );

      print('✅ Puzzle data loaded successfully: ${collectedPieces.length} pieces');
    } catch (e, stackTrace) {
      print('❌ Error loading puzzle data: $e');
      print('📍 Stack trace: $stackTrace');
      state = PuzzleError('Error al cargar los datos: $e');
    }
  }

  Future<CulturalPiece?> collectPieceByQr(String qrCode) async {
    try {
      // This method is no longer needed since QR scanner handles saving directly
      // Just reload the data
      await loadPuzzleData();
      return null;
    } catch (e) {
      print('❌ Error in collectPieceByQr: $e');
      return null;
    }
  }

  void selectCategory(String categoryId) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      state = currentState.copyWith(selectedCategoryId: categoryId);
    }
  }

  // Method to refresh data after QR scan
  Future<void> refreshAfterQRScan() async {
    print('🔄 Refreshing puzzle data after QR scan...');
    await loadPuzzleData();
  }
}
