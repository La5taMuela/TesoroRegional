import 'package:dartz/dartz.dart';
import 'package:tesoro_regional/core/utils/failures.dart';
import 'package:tesoro_regional/core/utils/typedefs.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/language_localized.dart';
import 'package:tesoro_regional/features/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:tesoro_regional/features/puzzle/data/datasources/puzzle_local_data_source.dart';
import 'package:tesoro_regional/features/puzzle/data/models/cultural_piece_dto.dart';
import 'package:tesoro_regional/features/qr_scanner/domain/repositories/qr_repository.dart';
import 'package:tesoro_regional/features/qr_scanner/domain/entities/qr_piece.dart';
import 'package:tesoro_regional/core/services/qr/qr_scanner_service.dart';

class PuzzleRepositoryImpl implements PuzzleRepository {
  final PuzzleLocalDataSource _localDataSource;
  final QRRepository _qrRepository;
  final QRScannerService _qrScannerService;

  PuzzleRepositoryImpl({
    required PuzzleLocalDataSource localDataSource,
    required QRRepository qrRepository,
    required QRScannerService qrScannerService,
  })  : _localDataSource = localDataSource,
        _qrRepository = qrRepository,
        _qrScannerService = qrScannerService;

  @override
  Future<Either<Failure, List<PieceCategory>>> getCategories() async {
    try {
      final categories = (await _localDataSource.getCategories())
          .map((dto) => dto.toDomain())
          .toList();

      return Right(categories);
    } catch (e) {
      return Left(ServerError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CulturalPiece>>> getCollectedPieces() async {
    try {
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
  Future<Either<Failure, CulturalPiece?>> getPieceById(String id) async {
    try {
      final pieceDto = await _localDataSource.getPieceById(id);
      if (pieceDto != null) {
        return Right(pieceDto.toDomain());
      }
      return Left(NotFound('Pieza con ID $id no encontrada'));
    } catch (e) {
      return const Left(CacheError());
    }
  }

  @override
  Future<Either<Failure, CulturalPiece?>> collectPieceByQr(String qrCode) async {
    try {
      // Use the new QR scanner service to process the QR code
      final scanResult = await _qrScannerService.scanAndProcessQR(qrCode);

      if (!scanResult.success || scanResult.piece == null) {
        return Left(InvalidInput(scanResult.errorMessage ?? 'Código QR inválido'));
      }

      final qrPiece = scanResult.piece!;

      // Check if we already have this piece
      final existingQrPiece = await _qrRepository.getPieceById(qrPiece.id);
      if (existingQrPiece != null) {
        // Convert existing QR piece to Cultural piece
        final culturalPiece = _convertQrPieceToCulturalPiece(existingQrPiece);
        return Right(culturalPiece);
      }

      // Save the QR piece
      await _qrRepository.savePiece(qrPiece);

      // Convert to cultural piece and save locally
      final culturalPiece = _convertQrPieceToCulturalPiece(qrPiece);
      final culturalPieceDto = CulturalPieceDto.fromDomain(culturalPiece);
      await _localDataSource.savePiece(culturalPieceDto);

      return Right(culturalPiece);
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
  Future<Either<Failure, CulturalPiece>> unlockPiece(String pieceId) async {
    try {
      await _localDataSource.unlockPiece(pieceId);

      final pieceDto = await _localDataSource.getPieceById(pieceId);
      if (pieceDto != null) {
        return Right(pieceDto.toDomain());
      }
      return Left(NotFound('Pieza con ID $pieceId no encontrada'));
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

  // Helper method to convert QRPiece to CulturalPiece
  CulturalPiece _convertQrPieceToCulturalPiece(QRPiece qrPiece) {
    return CulturalPiece(
      id: UniqueId.fromString(qrPiece.id),
      province: qrPiece.province,
      title: qrPiece.title,
      qrCode: qrPiece.code,
      category: _getDefaultCategory(qrPiece.province),
      descriptions: _getDefaultDescriptions(qrPiece.province, qrPiece.title),
      discoveredAt: qrPiece.collectedAt,
      isUnlocked: qrPiece.isCollected,
      imageUrl: _getProvinceImageUrl(qrPiece.province),
    );
  }

  // Helper methods for default data
  PieceCategory _getDefaultCategory(String province) {
    return const PieceCategory(
      id: 'provincias',
      name: 'Provincias',
      description: 'Provincias de la Región de Ñuble',
      iconPath: '',
      totalPieces: 3,
      collectedPieces: 0,
    );
  }

  List<LanguageLocalized> _getDefaultDescriptions(String province, String title) {
    final descriptions = {
      'itata': 'Provincia de Itata, conocida por sus viñedos y tradición vitivinícola.',
      'diguillin': 'Provincia de Diguillín, corazón administrativo de la región.',
      'punilla': 'Provincia de Punilla, tierra de montañas y tradiciones.',
    };

    return [
      LanguageLocalized(
        languageCode: 'es',
        text: descriptions[province.toLowerCase()] ?? 'Provincia de $province, Región de Ñuble.',
      ),
      LanguageLocalized(
        languageCode: 'en',
        text: '$province Province, Ñuble Region.',
      ),
    ];
  }

  String? _getProvinceImageUrl(String province) {
    final images = {
      'itata': '/placeholder.svg?height=200&width=300&text=Itata',
      'diguillin': '/placeholder.svg?height=200&width=300&text=Diguillín',
      'punilla': '/placeholder.svg?height=200&width=300&text=Punilla',
    };

    return images[province.toLowerCase()];
  }
}
