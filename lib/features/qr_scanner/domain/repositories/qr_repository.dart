import 'package:tesoro_regional/features/qr_scanner/data/datasources/qr_local_data_source.dart';
import 'package:tesoro_regional/features/qr_scanner/domain/entities/qr_piece.dart';

abstract class QRRepository {
  Future<void> savePiece(QRPiece piece);
  Future<List<QRPiece>> getAllPieces();
  Future<QRPiece?> getPieceById(String id);
  Future<int> getCollectedCount();
}

class QRLocalRepository implements QRRepository {
  final QRLocalDataSource localDataSource;

  QRLocalRepository(this.localDataSource);

  @override
  Future<List<QRPiece>> getAllPieces() => localDataSource.getAllPieces();

  @override
  Future<QRPiece?> getPieceById(String id) => localDataSource.getPieceById(id);

  @override
  Future<void> savePiece(QRPiece piece) => localDataSource.savePiece(piece);

  @override
  Future<int> getCollectedCount() => localDataSource.getCollectedCount();
}