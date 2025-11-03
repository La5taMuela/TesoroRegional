import 'package:encrypt/encrypt.dart';
import 'dart:typed_data';

class QREncryptionService {
  // Clave de exactamente 32 bytes (256 bits) para AES-256
  static final _keyBytes = Uint8List.fromList([
    84, 101, 115, 111, 114, 111, 82, 101, 103, 105, 111, 110, 97, 108, 78, 117,
    98, 108, 101, 50, 48, 50, 52, 83, 101, 99, 114, 101, 116, 75, 101, 121
  ]); // "TesoroRegionalNuble2024SecretKey" en bytes

  static final _key = Key(_keyBytes);
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encryptQRData(String data) {
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('Error encrypting QR data: $e');
      throw InvalidQRCodeException('Error al encriptar datos QR: ${e.toString()}');
    }
  }

  static String decryptQRData(String encryptedData) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      print('Error decrypting QR data: $e');
      throw InvalidQRCodeException('Código QR no válido para esta aplicación');
    }
  }
}

class InvalidQRCodeException implements Exception {
  final String message;
  InvalidQRCodeException(this.message);

  @override
  String toString() => 'InvalidQRCodeException: $message';
}
void testEncryption() {
  const qrCode = 'Ñuble-itata-provincia-vinicola-ITATA001';
  final encrypted = QREncryptionService.encryptQRData(qrCode);
  print('Encrypted QR: $encrypted');
}