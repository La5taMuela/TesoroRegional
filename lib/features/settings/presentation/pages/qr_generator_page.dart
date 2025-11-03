import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart'; // Reemplazamos image_gallery_saver con gal
import '../../../../core/data/fixed_qr_codes.dart';
import '../../../../core/services/storage/qr_storage_service.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final QRStorageService _qrStorageService = QRStorageService();

  List<Map<String, String>> _fixedQRCodes = [];
  List<Map<String, String>> _generatedQRCodes = [];
  bool _isLoading = true;
  String? _error;

  // GlobalKeys para capturar cada QR widget
  final Map<String, GlobalKey> _qrKeys = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQRCodes();
    _requestPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    // Solicitar permisos de almacenamiento usando gal
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }
    } catch (e) {
      print('Error requesting gallery permissions: $e');
    }
  }

  void _loadQRCodes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Cargar QR codes fijos
      _fixedQRCodes = FixedQRCodes.getAllQRCodes();

      // Crear GlobalKeys para cada QR
      for (final qrData in _fixedQRCodes) {
        _qrKeys[qrData['province']!] = GlobalKey();
      }

      // Cargar QR codes generados (guardados localmente)
      _generatedQRCodes = await _qrStorageService.getGeneratedQRCodes();

      // Crear GlobalKeys para QR generados también
      for (final qrData in _generatedQRCodes) {
        if (!_qrKeys.containsKey(qrData['province']!)) {
          _qrKeys[qrData['province']!] = GlobalKey();
        }
      }

      // Guardar los QR codes fijos como generados si no existen
      await _qrStorageService.saveGeneratedQRCodes();

      setState(() {
        _isLoading = false;
      });

      print('✅ QR codes loaded successfully');
    } catch (e) {
      print('❌ Error loading QR codes: $e');
      setState(() {
        _error = 'Error al cargar códigos QR: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Función para cargar la imagen del logo como ui.Image con bordes suaves
  Future<ui.Image> _loadLogoImage() async {
    final data = await rootBundle.load('assets/icon/icon_app.png');
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final originalImage = frame.image;

    // Crear una imagen con bordes suaves y borde externo
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 80.0; // Tamaño total incluyendo borde
    const imageSize = 60.0; // Tamaño de la imagen
    const borderWidth = 4.0;
    const offset = (size - imageSize) / 2;

    // Dibujar borde externo blanco
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, size, size),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Dibujar sombra suave
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 2, size - 4, size - 4),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    // Dibujar la imagen con bordes redondeados
    const imageRect = Rect.fromLTWH(offset, offset, imageSize, imageSize);
    final rrect = RRect.fromRectAndRadius(imageRect, const Radius.circular(8));

    canvas.clipRRect(rrect);
    canvas.drawImageRect(
      originalImage,
      Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
      imageRect,
      Paint(),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    picture.dispose();

    return img;
  }

  Future<void> _saveQRToGallery(Map<String, String> qrData) async {
    try {
      // Verificar permisos usando gal
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          throw Exception('Se requieren permisos de galería para guardar la imagen');
        }
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Guardando en galería...'),
              ],
            ),
          ),
        ),
      );

      Uint8List? qrImage;

      // Intentar capturar desde el widget en pantalla primero
      final qrKey = _qrKeys[qrData['province']!];
      if (qrKey?.currentContext != null) {
        try {
          final boundary = qrKey!.currentContext!.findRenderObject() as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 3.0);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

          if (byteData != null) {
            qrImage = byteData.buffer.asUint8List();
          }
        } catch (e) {
          print('Error capturing from widget: $e');
        }
      }

      // Si no se pudo capturar del widget, generar programáticamente
      if (qrImage == null) {
        print('Generating QR programmatically...');
        qrImage = await _generateQRImageWithLogo(qrData['qrCode']!, 1024);
      }

      // Crear archivo temporal
      final directory = await getTemporaryDirectory();
      final fileName = 'QR_${qrData['province']}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(qrImage);

      // Guardar en galería usando gal
      await Gal.putImage(file.path, album: 'Tesoro Regional QR');

      // Cerrar loading
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('QR de ${qrData['province']} guardado'),
                      const Text(
                        'Guardado en la galería de fotos',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Compartir',
              textColor: Colors.white,
              onPressed: () => _shareQRCode(qrData),
            ),
          ),
        );
      }

      // Limpiar archivo temporal
      try {
        await file.delete();
      } catch (e) {
        print('Error deleting temp file: $e');
      }

    } catch (e) {
      // Cerrar loading si está abierto
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('Error saving QR to gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Compartir',
              textColor: Colors.white,
              onPressed: () => _shareQRCode(qrData),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareQRCode(Map<String, String> qrData) async {
    try {
      // Capturar el QR widget que está en pantalla
      final qrKey = _qrKeys[qrData['province']!];
      if (qrKey?.currentContext == null) {
        throw Exception('No se pudo encontrar el QR en pantalla');
      }

      final boundary = qrKey!.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('No se pudo capturar la imagen del QR');
      }

      final qrImage = byteData.buffer.asUint8List();

      // Guardar archivo temporal para compartir
      final directory = await getTemporaryDirectory();
      final fileName = 'QR_${qrData['province']}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(qrImage);

      // Compartir archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Código QR - Provincia de ${qrData['province']}\n${qrData['description']}',
        subject: 'QR Code - ${qrData['province']}',
      );
    } catch (e) {
      print('Error sharing QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveAllQRCodes() async {
    try {
      // Verificar permisos
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          throw Exception('Se requieren permisos de galería');
        }
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Guardando todos los QR en galería...'),
                SizedBox(height: 8),
                Text(
                  'Esto puede tomar unos segundos',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );

      int savedCount = 0;
      final directory = await getTemporaryDirectory();

      for (final qrData in _fixedQRCodes) {
        try {
          // Intentar capturar desde el widget en pantalla
          final qrKey = _qrKeys[qrData['province']!];
          Uint8List qrImage;

          if (qrKey?.currentContext != null) {
            final boundary = qrKey!.currentContext!.findRenderObject() as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 3.0);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

            if (byteData != null) {
              qrImage = byteData.buffer.asUint8List();
            } else {
              qrImage = await _generateQRImageWithLogo(qrData['qrCode']!, 1024);
            }
          } else {
            // Fallback: generar QR si no está en pantalla
            qrImage = await _generateQRImageWithLogo(qrData['qrCode']!, 1024);
          }

          // Crear archivo temporal
          final fileName = 'QR_${qrData['province']}_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(qrImage);

          // Guardar en galería
          await Gal.putImage(file.path, album: 'Tesoro Regional QR');
          savedCount++;

          // Limpiar archivo temporal
          try {
            await file.delete();
          } catch (e) {
            print('Error deleting temp file: $e');
          }
        } catch (e) {
          print('Error saving QR for ${qrData['province']}: $e');
        }
      }

      Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$savedCount códigos QR guardados'),
                      const Text(
                        'Guardados en la galería de fotos',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('Error saving all QRs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generateQRImageWithLogo(String data, int size) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );

    if (!qrValidationResult.isValid) {
      throw Exception('QR data is not valid');
    }

    final qrCode = qrValidationResult.qrCode!;

    // Cargar el logo como ui.Image
    final logoImage = await _loadLogoImage();

    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
      gapless: false,
      embeddedImage: logoImage,
      embeddedImageStyle: const QrEmbeddedImageStyle(
        size: Size(80, 80), // Aumentar tamaño para incluir el borde
      ),
    );

    final picData = await painter.toImageData(size.toDouble(), format: ui.ImageByteFormat.png);
    if (picData == null) {
      throw Exception('Failed to generate QR image');
    }

    return picData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Códigos QR'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading && _error == null && _fixedQRCodes.isNotEmpty)
            IconButton(
              onPressed: _saveAllQRCodes,
              icon: const Icon(Icons.save_alt),
              tooltip: 'Guardar todos en galería',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.qr_code),
              text: 'QR Fijos',
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: 'QR Generados',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando códigos QR...'),
          ],
        ),
      )
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Error al Cargar QR Codes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadQRCodes,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildFixedQRTab(),
          _buildGeneratedQRTab(),
        ],
      ),
    );
  }

  Widget _buildFixedQRTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Códigos QR Oficiales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'QR codes con logo de la app incluido.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // QR Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fixedQRCodes.length,
            itemBuilder: (context, index) {
              final qrData = _fixedQRCodes[index];
              return _buildQRCard(qrData, isFixed: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedQRTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade50,
                  Colors.green.shade100,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QR Codes Guardados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tienes ${_generatedQRCodes.length} códigos QR guardados localmente.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_generatedQRCodes.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay QR codes guardados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Los QR codes se guardarán automáticamente cuando los generes.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _generatedQRCodes.length,
              itemBuilder: (context, index) {
                final qrData = _generatedQRCodes[index];
                return _buildQRCard(qrData, isFixed: false);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQRCard(Map<String, String> qrData, {required bool isFixed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HexColor(qrData['color']!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: HexColor(qrData['color']!),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provincia de ${qrData['province']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        qrData['title']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _saveQRToGallery(qrData),
                        icon: Icon(
                          Icons.save_alt,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        tooltip: 'Guardar en galería',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _shareQRCode(qrData),
                        icon: Icon(
                          Icons.share,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        tooltip: 'Compartir QR',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              qrData['description']!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // QR Code - Envuelto en RepaintBoundary para captura CON LOGO
            Center(
              child: RepaintBoundary(
                key: _qrKeys[qrData['province']!],
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData['qrCode']!,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    // AGREGAR LOGO EN EL CENTRO con mejor tamaño
                    embeddedImage: const AssetImage('assets/icon/icon_app.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(50, 50), // Tamaño optimizado para QR de 200px
                    ),
                    errorStateBuilder: (context, error) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Error al generar QR',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isFixed ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFixed ? Colors.blue.shade200 : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: isFixed ? Colors.blue.shade700 : Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isFixed
                          ? 'QR con logo oficial - Listo para escanear'
                          : 'QR code guardado localmente - Listo para escanear',
                      style: TextStyle(
                        fontSize: 13,
                        color: isFixed ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
