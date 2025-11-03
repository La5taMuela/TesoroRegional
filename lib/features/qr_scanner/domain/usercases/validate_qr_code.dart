import 'package:tesoro_regional/core/utils/qr_utils.dart';
import 'package:tesoro_regional/features/qr_scanner/domain/entities/qr_piece.dart';

class ValidateQRCode {
  QRPiece? call(String qrData) {
    final qrPieceData = QRUtils.parseQRData(qrData);
    return qrPieceData != null ? QRPiece.fromQRData(qrPieceData) : null;
  }
}