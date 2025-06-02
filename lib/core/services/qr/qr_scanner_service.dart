import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tesoro_regional/core/utils/qr_validator.dart';

abstract class QRScannerService {
  Future<String?> scanQR();
  Future<bool> requestCameraPermission();
  Future<bool> hasCameraPermission();
  Future<QRScanResult> validateAndProcessQR(String qrCode);
}

class QRScanResult {
  final bool isValid;
  final String? keyword;
  final String? errorMessage;
  final QRFormat format;

  QRScanResult({
    required this.isValid,
    this.keyword,
    this.errorMessage,
    required this.format,
  });
}

enum QRFormat { legacy, structured, invalid }

class QRScannerServiceImpl implements QRScannerService {

  @override
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<String?> scanQR() async {
    try {
      // Check camera permission first
      if (!await hasCameraPermission()) {
        final granted = await requestCameraPermission();
        if (!granted) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Permiso de cámara denegado',
          );
        }
      }

      // This will be handled by the QRScannerPage widget
      // The actual scanning is done through the UI
      return null;

    } on PlatformException catch (e) {
      print('Error scanning QR: ${e.message}');
      return null;
    }
  }

  @override
  Future<QRScanResult> validateAndProcessQR(String qrCode) async {
    if (!QRValidator.isValidTesoroRegionalCode(qrCode)) {
      return QRScanResult(
        isValid: false,
        errorMessage: QRValidator.getValidationErrorMessage(qrCode),
        format: QRFormat.invalid,
      );
    }

    final keyword = QRValidator.extractKeyword(qrCode);
    final format = QRValidator.isStructuredFormat(qrCode)
        ? QRFormat.structured
        : QRFormat.legacy;

    return QRScanResult(
      isValid: true,
      keyword: keyword,
      format: format,
    );
  }
}
