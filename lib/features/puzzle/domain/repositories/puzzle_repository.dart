import 'package:dartz/dartz.dart';
import 'package:tesoro_regional/core/utils/failures.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';

abstract class PuzzleRepository {
  Future<Either<Failure, List<PieceCategory>>> getCategories();
  Future<Either<Failure, List<CulturalPiece>>> getCollectedPieces();
  Future<Either<Failure, List<CulturalPiece>>> getPiecesByCategory(String categoryId);
  Future<Either<Failure, CulturalPiece?>> getPieceById(String id);
  Future<Either<Failure, CulturalPiece?>> collectPieceByQr(String qrCode);
  Future<Either<Failure, double>> getOverallCompletionPercentage();
  Future<Either<Failure, CulturalPiece>> unlockPiece(String pieceId);
  Future<Either<Failure, void>> savePiece(CulturalPiece piece);
}
