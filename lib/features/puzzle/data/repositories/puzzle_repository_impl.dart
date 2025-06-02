import 'package:dartz/dartz.dart';
import 'package:tesoro_regional/core/utils/failures.dart';
import 'package:tesoro_regional/core/utils/typedefs.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/geo_position.dart';
import 'package:tesoro_regional/features/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:tesoro_regional/features/puzzle/data/datasources/puzzle_local_data_source.dart';
import 'package:tesoro_regional/features/puzzle/data/datasources/puzzle_remote_data_source.dart';
import 'package:tesoro_regional/features/puzzle/data/models/cultural_piece_dto.dart';
import 'package:tesoro_regional/core/utils/qr_validator.dart';

class PuzzleRepositoryImpl implements PuzzleRepository {
  final PuzzleLocalDataSource _localDataSource;
  final PuzzleRemoteDataSource _remoteDataSource;

  PuzzleRepositoryImpl({
    required PuzzleLocalDataSource localDataSource,
    required PuzzleRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<PieceCategory>>> getCategories() async {
    try {
      // Try to get from local first
      List<PieceCategory> categories = (await _localDataSource.getCategories())
          .map((dto) => dto.toDomain())
          .toList();

      // If empty, fetch from remote
      if (categories.isEmpty) {
        final remoteCategoriesDto = await _remoteDataSource.getCategories();
        await _localDataSource.saveCategories(remoteCategoriesDto);
        categories = remoteCategoriesDto.map((dto) => dto.toDomain()).toList();
      }

      return Right(categories);
    } catch (e) {
      return Left(ServerError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CulturalPiece>>> getCollectedPieces() async {
    try {
      final localCategories = (await _localDataSource.getCategories())
          .map((dto) => dto.toDomain())
          .toList();

      if (localCategories.isEmpty) {
        return const Right([]);
      }

      final pieces = (await _localDataSource.getCollectedPieces())
          .map((dto) => dto.toDomain())
          .toList();

      return Right(pieces);
    } catch (e) {
      return const Left(CacheError());
    }
  }

  @override
  Future<Either<Failure, List<CulturalPiece>>> getPiecesByCategory(String categoryId) async {
    try {
      final pieces = (await _localDataSource.getPiecesByCategory(categoryId))
          .map((dto) => dto.toDomain())
          .toList();

      return Right(pieces);
    } catch (e) {
      return const Left(CacheError());
    }
  }

  @override
  Future<Either<Failure, CulturalPiece>> getPieceById(UniqueId id) async {
    try {
      final pieceDto = await _localDataSource.getPieceById(id.value);
      if (pieceDto != null) {
        return Right(pieceDto.toDomain());
      }
      return Left(NotFound('Pieza con ID ${id.value} no encontrada'));
    } catch (e) {
      return const Left(CacheError());
    }
  }

  @override
  Future<Either<Failure, CulturalPiece>> collectPieceByQr(String qrCode) async {
    try {
      // Verificar si el QR tiene el formato estructurado nuevo
      if (QRValidator.isStructuredFormat(qrCode)) {
        // Extraer el título del QR estructurado
        final keyword = QRValidator.extractKeyword(qrCode);

        if (keyword != null) {
          // Buscar una pieza basada en la palabra clave extraída
          final pieceDto = await _remoteDataSource.getPieceByKeyword(keyword);
          if (pieceDto != null) {
            // Guardar la pieza localmente
            final unlockablePiece = pieceDto.copyWith(
                isUnlocked: true,
                discoveredAt: DateTime.now()
            );
            await _localDataSource.savePiece(unlockablePiece);
            return Right(unlockablePiece.toDomain());
          }
        }
        return Left(InvalidInput('Código QR estructurado no reconocido o pieza no encontrada'));
      }

      // Verificar el formato tradicional "Ñuble-<identifier>"
      if (!QRValidator.isValidTesoroRegionalCode(qrCode)) {
        return Left(InvalidInput('Código QR inválido. ${QRValidator.getValidationErrorMessage(qrCode)}'));
      }

      // Procesar formato tradicional
      final pieceDto = await _remoteDataSource.getPieceByQrCode(qrCode);
      if (pieceDto != null) {
        // Guardar la pieza localmente
        final unlockablePiece = pieceDto.copyWith(
            isUnlocked: true,
            discoveredAt: DateTime.now()
        );
        await _localDataSource.savePiece(unlockablePiece);
        return Right(unlockablePiece.toDomain());
      }
      return Left(NotFound('No se encontró ninguna pieza con este código QR'));
    } catch (e) {
      return Left(NetworkError());
    }
  }

  @override
  Future<Either<Failure, CulturalPiece>> collectPieceByLocation(GeoPosition position) async {
    try {
      final pieceDto = await _remoteDataSource.getPieceByLocation(position.latitude, position.longitude);
      if (pieceDto != null) {
        // Save the piece locally
        final unlockablePiece = pieceDto.copyWith(isUnlocked: true, discoveredAt: DateTime.now());
        await _localDataSource.savePiece(unlockablePiece);
        return Right(unlockablePiece.toDomain());
      }
      return Left(NotFound('No se encontró ninguna pieza en esta ubicación'));
    } catch (e) {
      return Left(NetworkError());
    }
  }

  @override
  Future<Either<Failure, List<CulturalPiece>>> getPiecesByLocation(
      double latitude, double longitude, double radiusInMeters) async {
    try {
      final piecesDto = await _remoteDataSource.getNearbyPieces(latitude, longitude, radiusInMeters);
      final pieces = piecesDto.map((dto) => dto.toDomain()).toList();
      return Right(pieces);
    } catch (e) {
      return const Left(NetworkError());
    }
  }

  @override
  Future<Either<Failure, CulturalPiece?>> getPieceByLocation(double latitude, double longitude) async {
    try {
      final pieceDto = await _remoteDataSource.getPieceByLocation(latitude, longitude);
      if (pieceDto != null) {
        return Right(pieceDto.toDomain());
      }
      return const Left(NotFound('No se encontró ninguna pieza en esta ubicación'));
    } catch (e) {
      return const Left(NetworkError());
    }
  }

  @override
  Future<Either<Failure, List<CulturalPiece>>> getNearbyPieces(
      GeoPosition position, double radiusInMeters) async {
    try {
      final piecesDto = await _remoteDataSource.getNearbyPieces(
          position.latitude, position.longitude, radiusInMeters);
      final pieces = piecesDto.map((dto) => dto.toDomain()).toList();
      return Right(pieces);
    } catch (e) {
      return const Left(NetworkError());
    }
  }

  @override
  Future<Either<Failure, double>> getOverallCompletionPercentage() async {
    try {
      final percentage = await _localDataSource.getOverallCompletionPercentage();
      return Right(percentage);
    } catch (e) {
      return const Left(CacheError());
    }
  }

  @override
  Future<Either<Failure, CulturalPiece>> unlockPiece(UniqueId id) async {
    try {
      await _localDataSource.unlockPiece(id.value);
      await _remoteDataSource.unlockPiece(id.value);

      final pieceDto = await _localDataSource.getPieceById(id.value);
      if (pieceDto != null) {
        return Right(pieceDto.toDomain());
      }
      return Left(NotFound('Pieza con ID ${id.value} no encontrada'));
    } catch (e) {
      return Left(ServerError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePiece(CulturalPiece piece) async {
    try {
      final pieceDto = CulturalPieceDto.fromDomain(piece);
      await _localDataSource.savePiece(pieceDto);
      return const Right(null);
    } catch (e) {
      return const Left(CacheError());
    }
  }
}
