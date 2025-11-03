// QR Codes fijos para las provincias de Ñuble
class FixedQRCodes {
  static const Map<String, Map<String, String>> provinceQRCodes = {
    'itata': {
      'province': 'Itata',
      'title': 'Provincia Vinícola',
      'description': 'Provincia de Itata, conocida por sus viñedos y tradición vitivinícola ancestral.',
      'qrCode': 'Ñuble-itata-provincia-vinicola-ITATA001',
      'encryptedQR': 'gAAAAABnXYZ1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
      'color': '#9C27B0',
      'svgFile': 'itata.svg',
    },
    'diguillin': {
      'province': 'Diguillín',
      'title': 'Capital Regional',
      'description': 'Provincia de Diguillín, corazón administrativo de la región de Ñuble.',
      'qrCode': 'Ñuble-diguillin-capital-regional-DIGUI001',
      'encryptedQR': 'gAAAAABnXYZ9876543210zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA0987654321',
      'color': '#E91E63',
      'svgFile': 'diguillin.svg',
    },
    'punilla': {
      'province': 'Punilla',
      'title': 'Cordillera Andina',
      'description': 'Provincia de Punilla, tierra de montañas y tradiciones campesinas.',
      'qrCode': 'Ñuble-punilla-cordillera-andina-PUNIL001',
      'encryptedQR': 'gAAAAABnXYZ5555666677778888999900001111222233334444555566667777888899990000',
      'color': '#FF5722',
      'svgFile': 'punilla.svg',
    },
  };

  static List<Map<String, String>> getAllQRCodes() {
    return provinceQRCodes.values.toList();
  }

  static Map<String, String>? getQRCodeByProvince(String province) {
    return provinceQRCodes[province.toLowerCase()];
  }

  static Map<String, String>? getQRCodeByEncrypted(String encryptedQR) {
    for (final qrData in provinceQRCodes.values) {
      if (qrData['encryptedQR'] == encryptedQR) {
        return qrData;
      }
    }
    return null;
  }

  static Map<String, String>? getQRCodeByPlainText(String plainQR) {
    for (final qrData in provinceQRCodes.values) {
      if (qrData['qrCode'] == plainQR) {
        return qrData;
      }
    }
    return null;
  }
}
