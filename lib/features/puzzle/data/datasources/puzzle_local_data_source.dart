import 'dart:convert';
import 'package:tesoro_regional/core/services/storage/storage_service.dart';
import 'package:tesoro_regional/features/puzzle/data/models/cultural_piece_dto.dart';
import 'package:tesoro_regional/features/puzzle/data/models/piece_category_dto.dart';

abstract class PuzzleLocalDataSource {
  Future<List<CulturalPieceDto>> getCollectedPieces();
  Future<List<PieceCategoryDto>> getCategories();
  Future<void> saveCategories(List<PieceCategoryDto> categories);
  Future<void> savePiece(CulturalPieceDto piece);
  Future<void> updatePieceStatus(String id, bool isUnlocked);
  Future<CulturalPieceDto?> getPieceById(String id);
  Future<double> getOverallCompletionPercentage();
  Future<List<CulturalPieceDto>> getPiecesByCategory(String categoryId);
  Future<void> unlockPiece(String pieceId);
}

class PuzzleLocalDataSourceImpl implements PuzzleLocalDataSource {
  final StorageService _storageService;

  PuzzleLocalDataSourceImpl(this._storageService);

  static const String _piecesKey = 'collected_pieces';
  static const String _categoriesKey = 'categories';

  @override
  Future<List<CulturalPieceDto>> getCollectedPieces() async {
    final piecesJson = await _storageService.getString(_piecesKey);
    if (piecesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(piecesJson);
    return decoded.map((json) => CulturalPieceDto.fromJson(json)).toList();
  }

  @override
  Future<List<PieceCategoryDto>> getCategories() async {
    final categoriesJson = await _storageService.getString(_categoriesKey);
    if (categoriesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(categoriesJson);
    return decoded.map((json) => PieceCategoryDto.fromJson(json)).toList();
  }

  @override
  Future<void> saveCategories(List<PieceCategoryDto> categories) async {
    await _storageService.setString(_categoriesKey, jsonEncode(categories.map((c) => c.toJson()).toList()));
  }

  @override
  Future<void> savePiece(CulturalPieceDto piece) async {
    final pieces = await getCollectedPieces();
    final existingIndex = pieces.indexWhere((p) => p.id == piece.id);

    if (existingIndex >= 0) {
      pieces[existingIndex] = piece;
    } else {
      pieces.add(piece);
    }

    await _storageService.setString(_piecesKey, jsonEncode(pieces.map((p) => p.toJson()).toList()));
  }

  @override
  Future<void> updatePieceStatus(String id, bool isUnlocked) async {
    final pieces = await getCollectedPieces();
    final index = pieces.indexWhere((p) => p.id == id);

    if (index >= 0) {
      pieces[index] = pieces[index].copyWith(isUnlocked: isUnlocked);
      await _storageService.setString(_piecesKey, jsonEncode(pieces.map((p) => p.toJson()).toList()));
    }
  }

  @override
  Future<CulturalPieceDto?> getPieceById(String id) async {
    final pieces = await getCollectedPieces();
    try {
      return pieces.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<double> getOverallCompletionPercentage() async {
    final pieces = await getCollectedPieces();
    if (pieces.isEmpty) return 0.0;

    final unlockedCount = pieces.where((p) => p.isUnlocked).length;
    return (unlockedCount / pieces.length) * 100;
  }

  @override
  Future<List<CulturalPieceDto>> getPiecesByCategory(String categoryId) async {
    final pieces = await getCollectedPieces();
    return pieces.where((p) => p.category.id == categoryId).toList();
  }

  @override
  Future<void> unlockPiece(String pieceId) async {
    await updatePieceStatus(pieceId, true);
  }
}
