import 'package:tesoro_regional/features/qr_scanner/domain/entities/qr_piece.dart';
import 'package:tesoro_regional/features/qr_scanner/domain/repositories/qr_repository.dart';

class ProcessQRPiece {
  final QRRepository repository;

  ProcessQRPiece(this.repository);

  Future<QRPiece> call(QRPiece piece) async {
    await repository.savePiece(piece);
    return piece;
  }
}