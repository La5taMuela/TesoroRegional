import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/fixed_qr_codes.dart';

class QRStorageService {
  static const String _generatedQRsKey = 'generated_qr_codes';
  static const String _scannedQRsKey = 'scanned_qr_codes';

  // Guardar QR codes generados localmente
  Future<void> saveGeneratedQRCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final qrCodes = FixedQRCodes.getAllQRCodes();
      final qrCodesJson = qrCodes.map((qr) => json.encode(qr)).toList();

      await prefs.setStringList(_generatedQRsKey, qrCodesJson);
      print('✅ Generated QR codes saved locally');
    } catch (e) {
      print('❌ Error saving generated QR codes: $e');
    }
  }

  // Obtener QR codes generados
  Future<List<Map<String, String>>> getGeneratedQRCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final qrCodesJson = prefs.getStringList(_generatedQRsKey);

      if (qrCodesJson == null || qrCodesJson.isEmpty) {
        // Si no hay QR codes guardados, usar los fijos y guardarlos
        await saveGeneratedQRCodes();
        return FixedQRCodes.getAllQRCodes();
      }

      return qrCodesJson.map((qrJson) {
        final qrMap = json.decode(qrJson) as Map<String, dynamic>;
        return qrMap.map((key, value) => MapEntry(key, value.toString()));
      }).toList();
    } catch (e) {
      print('❌ Error loading generated QR codes: $e');
      return FixedQRCodes.getAllQRCodes();
    }
  }

  // Marcar QR como escaneado
  Future<void> markQRAsScanned(String qrCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scannedQRs = prefs.getStringList(_scannedQRsKey) ?? [];

      if (!scannedQRs.contains(qrCode)) {
        scannedQRs.add(qrCode);
        await prefs.setStringList(_scannedQRsKey, scannedQRs);
        print('✅ QR marked as scanned: $qrCode');
      }
    } catch (e) {
      print('❌ Error marking QR as scanned: $e');
    }
  }

  // Verificar si QR fue escaneado
  Future<bool> isQRScanned(String qrCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scannedQRs = prefs.getStringList(_scannedQRsKey) ?? [];
      return scannedQRs.contains(qrCode);
    } catch (e) {
      print('❌ Error checking if QR is scanned: $e');
      return false;
    }
  }

  // Obtener QRs escaneados
  Future<List<String>> getScannedQRs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_scannedQRsKey) ?? [];
    } catch (e) {
      print('❌ Error getting scanned QRs: $e');
      return [];
    }
  }

  // Limpiar todos los datos
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_generatedQRsKey);
      await prefs.remove(_scannedQRsKey);
      print('✅ All QR data cleared');
    } catch (e) {
      print('❌ Error clearing QR data: $e');
    }
  }
}
