import 'qr_utils.dart';
import '../data/fixed_qr_codes.dart';
import '../services/qr/qr_encryption_service.dart';

class QRValidator {
  static QRValidationResult validateQRCode(String qrData) {
    print('🔄 Validating QR: $qrData'); // <- Añade este log

    // 1. Compara con encryptedQR
    final fixedByEncrypted = FixedQRCodes.getQRCodeByEncrypted(qrData);
    if (fixedByEncrypted != null) {
      print('✅ QR matches fixed encrypted code');
      return QRValidationResult.success(_createPieceDataFromFixed(fixedByEncrypted));
    }

    // 2. Intenta desencriptar
    try {
      final decrypted = QREncryptionService.decryptQRData(qrData);
      print('🔓 Decrypted QR: $decrypted');

      // Compara con qrCode sin encriptar
      final fixedByPlain = FixedQRCodes.getQRCodeByPlainText(decrypted);
      if (fixedByPlain != null) {
        print('✅ QR matches fixed plain code');
        return QRValidationResult.success(_createPieceDataFromFixed(fixedByPlain));
      }
    } catch (e) {
      print('⚠️ QR is not encrypted: $e');
    }

    // 3. Compara directamente con qrCode (sin encriptar)
    final fixedByPlain = FixedQRCodes.getQRCodeByPlainText(qrData);
    if (fixedByPlain != null) {
      print('✅ QR matches fixed plain code (direct)');
      return QRValidationResult.success(_createPieceDataFromFixed(fixedByPlain));
    }

    return QRValidationResult.error('QR no reconocido');
  }

  static QRPieceData _createPieceDataFromFixed(Map<String, String> fixedQR) {
    // Extraer información del QR code fijo
    final qrCode = fixedQR['qrCode']!;
    final parts = qrCode.split('-');

    if (parts.length >= 4) {
      return QRPieceData(
        province: parts[1], // itata, diguillin, punilla
        title: '${parts[2]}-${parts[3]}', // provincia-vinicola, capital-regional, etc.
        code: parts.length > 4 ? parts[4] : 'DEFAULT',
      );
    }

    // Fallback
    return QRPieceData(
      province: fixedQR['province']!.toLowerCase(),
      title: fixedQR['title']!.toLowerCase().replaceAll(' ', '-'),
      code: 'FIXED001',
    );
  }
}

class QRValidationResult {
  final bool isValid;
  final QRPieceData? pieceData;
  final String message;

  QRValidationResult._({
    required this.isValid,
    this.pieceData,
    required this.message,
  });

  factory QRValidationResult.success(QRPieceData pieceData) {
    return QRValidationResult._(
      isValid: true,
      pieceData: pieceData,
      message: 'QR válido',
    );
  }

  factory QRValidationResult.error(String message) {
    return QRValidationResult._(
      isValid: false,
      message: message,
    );
  }
}
