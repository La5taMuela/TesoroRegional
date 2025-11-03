import 'package:tesoro_regional/core/services/qr/qr_encryption_service.dart';
import 'package:tesoro_regional/features/qr_scanner/domain/entities/qr_piece.dart';
import 'package:tesoro_regional/core/utils/qr_utils.dart';

class QRScannerService {
  Future<QRScanResult> scanAndProcessQR(String rawData) async {
    try {
      // Primero intentamos desencriptar el QR
      String decryptedData;
      try {
        decryptedData = QREncryptionService.decryptQRData(rawData);
      } catch (_) {
        // Si no se puede desencriptar, no es un QR válido de nuestra app
        return QRScanResult.error('Este código QR no pertenece a la aplicación Tesoro Regional');
      }

      // Validamos la estructura del QR desencriptado
      final qrData = QRUtils.parseQRData(decryptedData);

      if (qrData == null) {
        return QRScanResult.error('Formato de QR inválido para Tesoro Regional');
      }

      // Creamos la pieza desde los datos del QR
      final piece = QRPiece.fromQRData(qrData);

      return QRScanResult.success(piece);
    } on InvalidQRCodeException catch (e) {
      return QRScanResult.error('QR inválido: ${e.message}');
    } catch (e) {
      return QRScanResult.error('Este código QR no es compatible con Tesoro Regional');
    }
  }
}

class QRScanResult {
  final bool success;
  final QRPiece? piece;
  final String? errorMessage;

  QRScanResult.success(this.piece)
      : success = true, errorMessage = null;

  QRScanResult.error(this.errorMessage)
      : success = false, piece = null;
}
