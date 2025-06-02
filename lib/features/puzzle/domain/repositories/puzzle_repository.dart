import 'package:dartz/dartz.dart';
import 'package:tesoro_regional/core/utils/failures.dart';
import 'package:tesoro_regional/core/utils/typedefs.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/geo_position.dart';

abstract class PuzzleRepository {
  /// Get all available piece categories
  Future<Either<Failure, List<PieceCategory>>> getCategories();

  /// Get all collected pieces
  Future<Either<Failure, List<CulturalPiece>>> getCollectedPieces();

  /// Get pieces by category
  Future<Either<Failure, List<CulturalPiece>>> getPiecesByCategory(String categoryId);

  /// Get a specific piece by ID
  Future<Either<Failure, CulturalPiece>> getPieceById(UniqueId id);

  /// Collect a piece by QR code
  Future<Either<Failure, CulturalPiece>> collectPieceByQr(String qrCode);

  /// Collect a piece by geolocation
  Future<Either<Failure, CulturalPiece>> collectPieceByLocation(GeoPosition position);

  /// Get nearby pieces within a radius
  Future<Either<Failure, List<CulturalPiece>>> getNearbyPieces(
      GeoPosition position,
      double radiusInMeters,
      );

  /// Unlock a piece that has been collected but not yet unlocked
  Future<Either<Failure, CulturalPiece>> unlockPiece(UniqueId id);

  /// Get overall puzzle completion percentage
  Future<Either<Failure, double>> getOverallCompletionPercentage();
}