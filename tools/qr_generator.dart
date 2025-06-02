import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

class QRGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _random = Random();
  static const String codesFilePath = 'tools/generated_codes.txt';
  static const String qrOutputDir = 'tools/generated_qr';

  /// Genera un sufijo aleatorio para los códigos QR
  static String generateRandomSuffix([int length = 6]) {
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => _chars.codeUnitAt(_random.nextInt(_chars.length)),
      ),
    );
  }

  /// Limpia una palabra para que contenga solo caracteres alfanuméricos
  static String cleanWord(String word) {
    return word.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  /// Genera un código QR de Tesoro Regional con el formato "Ñuble-[palabra][sufijo]"
  static String generateTesoroRegionalCode(String word) {
    final cleanedWord = cleanWord(word);
    if (cleanedWord.isEmpty) {
      throw ArgumentError('La palabra debe contener al menos un carácter alfanumérico');
    }

    final suffix = generateRandomSuffix();
    return 'Ñuble-$cleanedWord$suffix';
  }

  /// Guarda el código QR generado en un archivo de registro
  static Future<void> saveCodeToRegistry(String code, String keyword) async {
    final file = File(codesFilePath);
    final timestamp = DateTime.now().toIso8601String();
    final entry = '$timestamp | $code | $keyword\n';

    if (await file.exists()) {
      await file.writeAsString(entry, mode: FileMode.append);
    } else {
      await file.writeAsString(
          'FECHA | CÓDIGO | PALABRA CLAVE\n' +
              '--------------------------------\n' +
              entry
      );
    }

    print('Código guardado en el registro: $codesFilePath');
  }

  /// Genera una imagen QR a partir de un código
  static Uint8List generateQRImage(String code, {int size = 300}) {
    // Crear el QR
    final qr = QrCode.fromData(
      data: code,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );

    // Convertir a imagen
    final qrImage = QrImage(qr);

    // Crear una imagen en blanco
    final image = img.Image(width: size, height: size);

    // Rellenar con blanco
    img.fill(image, color: img.ColorRgb8(255, 255, 255));

    // Calcular el tamaño de cada módulo QR
    final moduleSize = size / qr.moduleCount;

    // Dibujar el QR
    for (int x = 0; x < qr.moduleCount; x++) {
      for (int y = 0; y < qr.moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          // Dibujar un módulo negro
          final xPos = (x * moduleSize).round();
          final yPos = (y * moduleSize).round();
          final moduleWidth = moduleSize.ceil();

          img.fillRect(
            image,
            x1: xPos,
            y1: yPos,
            x2: xPos + moduleWidth,
            y2: yPos + moduleWidth,
            color: img.ColorRgb8(0, 0, 0),
          );
        }
      }
    }

    // Convertir a PNG
    return Uint8List.fromList(img.encodePng(image));
  }

  /// Guarda el código QR como una imagen PNG
  static Future<void> saveQRToFile(String code, String keyword) async {
    final directory = Directory(qrOutputDir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filename = 'qr_${keyword}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${directory.path}/$filename');

    // Generar la imagen QR
    final qrImageBytes = generateQRImage(code);

    // Guardar la imagen
    await file.writeAsBytes(qrImageBytes);
    print('Imagen QR guardada en: ${file.path}');

    // También guardamos el código en el registro central
    await saveCodeToRegistry(code, keyword);

    // Crear un archivo de información
    final infoFile = File('${directory.path}/${filename.replaceAll('.png', '_info.txt')}');
    final infoContent = '''
INFORMACIÓN DEL QR GENERADO
===================================
Palabra clave: $keyword
Generado: ${DateTime.now().toIso8601String()}

INSTRUCCIONES:
1. Imprime el QR y colócalo en la ubicación correspondiente
2. Los usuarios podrán escanearlo con la app Tesoro Regional para desbloquear la pieza
''';

    await infoFile.writeAsString(infoContent);
  }
}

/// CLI interactiva para generar códigos QR
class QRGeneratorCLI {
  static Future<void> run() async {
    print('🧩 Generador de QR para Tesoro Regional');
    print('==================================\n');

    while (true) {
      print('Selecciona una opción:');
      print('1. Generar código QR para pieza de puzzle');
      print('2. Ver códigos generados');
      print('3. Salir');
      print('\nIngresa tu elección (1-3): ');

      final choice = stdin.readLineSync()?.trim();

      switch (choice) {
        case '1':
          await _generateQR();
          break;
        case '2':
          await _viewGeneratedCodes();
          break;
        case '3':
          print('¡Hasta luego! 👋');
          return;
        default:
          print('Opción inválida. Intenta de nuevo.\n');
      }
    }
  }

  static Future<void> _generateQR() async {
    print('\n🧩 Generar código QR para pieza de puzzle');
    print('Ingresa una palabra clave (ej: plaza, mercado, museo): ');
    final keyword = stdin.readLineSync()?.trim();

    if (keyword == null || keyword.isEmpty) {
      print('❌ La palabra clave no puede estar vacía.\n');
      return;
    }

    try {
      final qrCode = QRGenerator.generateTesoroRegionalCode(keyword);
      print('\n🎯 Código generado y guardado en el registro');

      await QRGenerator.saveQRToFile(qrCode, keyword.toLowerCase());
      print('✅ Imagen QR generada y guardada exitosamente.\n');
    } catch (e) {
      print('❌ Error: $e\n');
    }
  }

  static Future<void> _viewGeneratedCodes() async {
    final file = File(QRGenerator.codesFilePath);
    if (!await file.exists()) {
      print('\n❌ No hay códigos generados todavía.\n');
      return;
    }

    final content = await file.readAsString();
    print('\n📋 CÓDIGOS QR GENERADOS:');
    print('====================\n');
    print(content);
    print('\n');
  }
}

/// Función principal para ejecutar el generador de QR
void main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    // Modo línea de comandos
    if (arguments[0] == 'generate') {
      if (arguments.length < 2) {
        print('Uso: dart qr_generator.dart generate <palabra_clave>');
        return;
      }
      final keyword = arguments[1];

      try {
        final qrCode = QRGenerator.generateTesoroRegionalCode(keyword);
        print('Código QR generado y guardado en el registro');
        await QRGenerator.saveQRToFile(qrCode, keyword.toLowerCase());
      } catch (e) {
        print('Error: $e');
      }
    } else if (arguments[0] == 'list') {
      final file = File(QRGenerator.codesFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        print('CÓDIGOS QR GENERADOS:\n');
        print(content);
      } else {
        print('No hay códigos generados todavía.');
      }
    } else {
      print('Comando desconocido: ${arguments[0]}');
      print('Comandos disponibles: generate, list');
    }
  } else {
    // Modo interactivo
    await QRGeneratorCLI.run();
  }
}
