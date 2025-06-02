/// Utility class for validating QR codes in the Tesoro Regional app
class QRValidator {
  /// Validates if a QR code follows the Tesoro Regional format (old or new)
  static bool isValidTesoroRegionalCode(String qrCode) {
    // Check new structured format
    if (qrCode.startsWith('TESORO REGIONAL')) {
      return _isValidStructuredFormat(qrCode);
    }

    // Check old format: QR code must start with "Ñuble-" followed by alphanumeric characters
    final regex = RegExp(r'^Ñuble-[a-zA-Z0-9]+$');
    return regex.hasMatch(qrCode);
  }

  /// Validates the new structured format
  static bool _isValidStructuredFormat(String qrCode) {
    // Must contain required fields
    return qrCode.contains('Tipo: Pieza Cultural') &&
        qrCode.contains('Título:') &&
        qrCode.contains('ID:');
  }

  /// Extracts the keyword from a QR code (works with both formats)
  static String? extractKeyword(String qrCode) {
    if (qrCode.startsWith('TESORO REGIONAL')) {
      return _extractKeywordFromStructured(qrCode);
    }

    // Old format
    if (!isValidTesoroRegionalCode(qrCode)) {
      return null;
    }
    return qrCode.substring(6); // Remove "Ñuble-" prefix
  }

  /// Extracts keyword from structured format
  static String? _extractKeywordFromStructured(String qrCode) {
    final titleMatch = RegExp(r'Título:\s*([A-Z]+)', caseSensitive: false).firstMatch(qrCode);
    if (titleMatch != null && titleMatch.groupCount >= 1) {
      return titleMatch.group(1)?.toLowerCase();
    }
    return null;
  }

  /// Gets a user-friendly error message for invalid QR codes
  static String getValidationErrorMessage(String qrCode, [String languageCode = 'es']) {
    if (qrCode.isEmpty) {
      return languageCode == 'es'
          ? 'El código QR está vacío'
          : 'QR code is empty';
    }

    if (!qrCode.startsWith('Ñuble-') && !qrCode.startsWith('TESORO REGIONAL')) {
      return languageCode == 'es'
          ? 'El código QR debe ser de Tesoro Regional (comenzar con "Ñuble-" o "TESORO REGIONAL")'
          : 'QR code must be from Tesoro Regional (start with "Ñuble-" or "TESORO REGIONAL")';
    }

    if (qrCode.startsWith('TESORO REGIONAL')) {
      if (!qrCode.contains('Título:')) {
        return languageCode == 'es'
            ? 'El código QR no contiene información de título válida'
            : 'QR code does not contain valid title information';
      }
      return languageCode == 'es'
          ? 'Código QR estructurado inválido'
          : 'Invalid structured QR code';
    }

    // Old format validation
    if (qrCode.length <= 6) {
      return languageCode == 'es'
          ? 'El código QR debe tener contenido después de "Ñuble-"'
          : 'QR code must have content after "Ñuble-"';
    }

    final keyword = qrCode.substring(6);
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(keyword)) {
      return languageCode == 'es'
          ? 'El código QR solo puede contener letras y números después de "Ñuble-"'
          : 'QR code can only contain letters and numbers after "Ñuble-"';
    }

    return languageCode == 'es' ? 'Código QR inválido' : 'Invalid QR code';
  }

  /// Checks if a QR code is likely a test code (contains common test keywords)
  static bool isTestCode(String qrCode) {
    final keyword = extractKeyword(qrCode);
    if (keyword == null) return false;

    const testKeywords = [
      'test',
      'prueba',
      'demo',
      'ejemplo',
      'sample',
    ];

    return testKeywords.any((testKeyword) => keyword.contains(testKeyword));
  }

  /// Checks if QR code uses the new structured format
  static bool isStructuredFormat(String qrCode) {
    return qrCode.startsWith('TESORO REGIONAL');
  }

  /// Generates example QR codes for documentation/testing
  static List<String> getExampleQRCodes() {
    return [
      'Ñuble-plaza001',
      'Ñuble-mercado002',
      'Ñuble-museo003',
      'Ñuble-artesania004',
      'Ñuble-tradicion005',
      'Ñuble-catedral006',
      'Ñuble-monumento007',
      'Ñuble-cultura008',
      'TESORO REGIONAL\nTipo: Pieza Cultural\nTítulo: PLAZA\nID: ****Ab',
      'TESORO REGIONAL\nTipo: Pieza Cultural\nTítulo: MERCADO\nID: ****Z8',
    ];
  }
}
