import 'dart:math';
import '../services/qr/qr_encryption_service.dart';

class QRUtils {
  static final _qrRegex = RegExp(
      r'^Ñuble-(itata|diguillin|punilla)-([a-zA-Z0-9\-]+)-([a-zA-Z0-9]{8})$',
      caseSensitive: false
  );

  static bool isValidQRFormat(String qrData) {
    return _qrRegex.hasMatch(qrData);
  }

  static QRPieceData? parseQRData(String qrData) {
    if (!isValidQRFormat(qrData)) return null;

    final match = _qrRegex.firstMatch(qrData)!;
    return QRPieceData(
      province: match.group(1)!,
      title: match.group(2)!,
      code: match.group(3)!,
    );
  }

  static String generateQRCode(String province, String title) {
    final randomCode = _generateRandomCode(8);
    return 'Ñuble-${province.toLowerCase()}-${title.toLowerCase()}-$randomCode';
  }

  static String generateEncryptedQRCode(String province, String title) {
    final qrCode = generateQRCode(province, title);
    return QREncryptionService.encryptQRData(qrCode);
  }

  /// Procesa un QR code escaneado (puede estar encriptado o no)
  static QRProcessResult processScannedQR(String scannedData) {
    try {
      // Primero intentar como QR encriptado
      try {
        final decryptedData = QREncryptionService.decryptQRData(scannedData);
        print('✅ QR decrypted successfully');

        if (isValidQRFormat(decryptedData)) {
          final pieceData = parseQRData(decryptedData);
          if (pieceData != null) {
            return QRProcessResult.success(pieceData);
          }
        }
        return QRProcessResult.error('Formato de QR inválido después de desencriptar');
      } catch (e) {
        // Si falla la desencriptación, intentar como QR sin encriptar
        print('QR is not encrypted, trying direct validation');

        if (isValidQRFormat(scannedData)) {
          final pieceData = parseQRData(scannedData);
          if (pieceData != null) {
            return QRProcessResult.success(pieceData);
          }
        }

        return QRProcessResult.error('Código QR no válido para Tesoro Regional');
      }
    } catch (e) {
      print('Error processing QR: $e');
      return QRProcessResult.error('Error al procesar código QR');
    }
  }

  static String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
        Iterable.generate(
            length,
                (_) => chars.codeUnitAt(random.nextInt(chars.length))
        )
    );
  }
}

class QRPieceData {
  final String province;
  final String title;
  final String code;

  QRPieceData({
    required this.province,
    required this.title,
    required this.code,
  });

  @override
  String toString() => 'QRPieceData(province: $province, title: $title, code: $code)';
}

class QRProcessResult {
  final bool isSuccess;
  final QRPieceData? pieceData;
  final String? error;

  QRProcessResult._({
    required this.isSuccess,
    this.pieceData,
    this.error,
  });

  factory QRProcessResult.success(QRPieceData pieceData) {
    return QRProcessResult._(
      isSuccess: true,
      pieceData: pieceData,
    );
  }

  factory QRProcessResult.error(String error) {
    return QRProcessResult._(
      isSuccess: false,
      error: error,
    );
  }
}
