import 'package:dartz/dartz.dart';
import 'package:tesoro_regional/core/utils/failures.dart';
import 'package:tesoro_regional/core/utils/usecase.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/domain/repositories/puzzle_repository.dart';

class CollectPieceByQrParams {
  final String qrCode;

  CollectPieceByQrParams({required this.qrCode});
}

class CollectPieceByQr implements UseCase<CulturalPiece, CollectPieceByQrParams> {
  final PuzzleRepository repository;

  CollectPieceByQr(this.repository);

  @override
  Future<Either<Failure, CulturalPiece>> call(CollectPieceByQrParams params) {
    return repository.collectPieceByQr(params.qrCode);
  }
}