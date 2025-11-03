import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/services/qr/web_qr_scanner_service.dart';
import '../../../../core/utils/qr_validator.dart';
import '../../../../core/services/storage/unified_pieces_storage.dart';
import '../../domain/entities/qr_piece.dart';
import '../../../puzzle/presentation/providers/puzzle_providers.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;

class WebQRScannerPage extends ConsumerStatefulWidget {
  final Function(QRPiece?)? onPieceScanned;

  const WebQRScannerPage({super.key, this.onPieceScanned});

  @override
  ConsumerState<WebQRScannerPage> createState() => _WebQRScannerPageState();
}

class _WebQRScannerPageState extends ConsumerState<WebQRScannerPage> {
  MobileScannerController? controller;
  bool _isProcessing = false;
  bool _hasPermission = false;
  bool _isInitializing = true;
  String? _errorMessage;
  QRPiece? _currentScannedPiece;
  final UnifiedPiecesStorage _storage = UnifiedPiecesStorage.instance;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        // Verificar soporte web
        if (!WebQRScannerService.isWebSupported) {
          setState(() {
            _errorMessage = 'Tu navegador no soporta acceso a cámara';
            _isInitializing = false;
          });
          return;
        }

        // Verificar HTTPS
        if (!html.window.location.protocol.startsWith('https')) {
          setState(() {
            _errorMessage = 'Se requiere HTTPS para acceder a la cámara';
            _isInitializing = false;
          });
          return;
        }

        // Solicitar permisos
        final hasPermission = await WebQRScannerService.requestCameraPermission();
        if (!hasPermission) {
          setState(() {
            _errorMessage = 'Permisos de cámara denegados';
            _hasPermission = false;
            _isInitializing = false;
          });
          return;
        }
      }

      // Inicializar el controlador con configuración específica para web
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      await controller!.start();

      setState(() {
        _hasPermission = true;
        _isInitializing = false;
      });

    } catch (e) {
      print('Error initializing scanner: $e');
      setState(() {
        _errorMessage = 'Error al inicializar la cámara: ${e.toString()}';
        _hasPermission = false;
        _isInitializing = false;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      print('🔍 QR Code detected (content hidden for security)');

      // Validar el QR code
      final validationResult = QRValidator.validateQRCode(code);

      if (validationResult.isValid && validationResult.pieceData != null) {
        final pieceData = validationResult.pieceData!;

        print('✅ Valid QR for province: ${pieceData.province}');

        // Crear QRPiece con los parámetros correctos
        final qrPiece = QRPiece(
          id: '${pieceData.province}_${pieceData.code}',
          province: pieceData.province,
          title: pieceData.title,
          code: pieceData.code,
          collectedAt: DateTime.now(),
          isCollected: true,
        );

        _currentScannedPiece = qrPiece;

        // Guardar la pieza usando el almacenamiento unificado
        try {
          final saved = await _storage.saveQRPiece(qrPiece);

          if (saved) {
            print('✅ Piece saved successfully to unified storage: ${qrPiece.id}');

            // Refresh puzzle data
            ref.read(puzzleStateProvider.notifier).refreshAfterQRScan();

            // Mostrar diálogo de éxito
            await _showSuccessDialog();

            // Notificar al callback si existe
            if (widget.onPieceScanned != null) {
              widget.onPieceScanned!(qrPiece);
            }
          } else {
            print('⚠️ Piece already exists: ${qrPiece.id}');
            await _showErrorDialog(
              'Pieza Ya Coleccionada',
              'Ya tienes esta pieza en tu colección.',
            );
          }
        } catch (storageError) {
          print('❌ Error saving piece: $storageError');
          await _showErrorDialog(
            'Error al Guardar Pieza',
            'No se pudo guardar la pieza. Inténtalo de nuevo.',
          );
        }
      } else {
        print('❌ Invalid QR: ${validationResult.message}');
        await _showErrorDialog(
          'Código QR Inválido',
          validationResult.message,
        );
      }
    } catch (e) {
      print('❌ Error processing QR: $e');
      await _showErrorDialog(
        'Error al Procesar QR',
        'Ocurrió un error al procesar el código QR. Inténtalo de nuevo.',
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('¡Pieza Coleccionada!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has coleccionado exitosamente una pieza de la provincia de ${_currentScannedPiece!.province.toUpperCase()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentScannedPiece!.title,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/collected-pieces');
            },
            child: const Text('Ver Progreso'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar Escaneando'),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? 'Error de Cámara',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Verifica que:\n• Estés usando HTTPS\n• Hayas dado permisos de cámara\n• Tu navegador soporte cámara web',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeScanner,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Inicializando cámara...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner QR'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_hasPermission && controller != null) ...[
            IconButton(
              onPressed: () => controller!.toggleTorch(),
              icon: const Icon(Icons.flash_on),
            ),
            IconButton(
              onPressed: () => controller!.switchCamera(),
              icon: const Icon(Icons.camera_front),
            ),
          ],
        ],
      ),
      body: _isInitializing
          ? _buildLoadingView()
          : !_hasPermission || _errorMessage != null
              ? _buildErrorView()
              : Stack(
                  children: [
                    // Scanner
                    if (controller != null)
                      MobileScanner(
                        controller: controller!,
                        onDetect: _onDetect,
                      ),

                    // Overlay
                    Container(
                      decoration: ShapeDecoration(
                        shape: QrScannerOverlayShape(
                          borderColor: Theme.of(context).primaryColor,
                          borderRadius: 16,
                          borderLength: 40,
                          borderWidth: 4,
                          cutOutSize: 280,
                        ),
                      ),
                    ),

                    // Instructions
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Escanea un código QR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Coloca el código QR dentro del marco para escanearlo',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (kIsWeb) ...[
                              SizedBox(height: 8),
                              Text(
                                '💡 Asegúrate de estar usando HTTPS',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Processing indicator
                    if (_isProcessing)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Procesando código QR...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

// Reutilizar la clase QrScannerOverlayShape del archivo original
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderHeightSize = height / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      borderWidthSize - cutOutWidth / 2,
      borderHeightSize - cutOutHeight / 2,
      cutOutWidth,
      cutOutHeight,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        backgroundPaint..blendMode = BlendMode.clear,
      )
      ..restore();

    final borderRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    final path = Path()
      ..addRRect(borderRect);

    canvas.drawPath(path, boxPaint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final left = cutOutRect.left;
    final top = cutOutRect.top;
    final right = cutOutRect.right;
    final bottom = cutOutRect.bottom;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + borderLength),
      Offset(left, top + borderRadius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + borderRadius, top),
      Offset(left + borderLength, top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(right - borderLength, top),
      Offset(right - borderRadius, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(right, top + borderRadius),
      Offset(right, top + borderLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, bottom - borderLength),
      Offset(left, bottom - borderRadius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + borderRadius, bottom),
      Offset(left + borderLength, bottom),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(right - borderLength, bottom),
      Offset(right - borderRadius, bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(right, bottom - borderRadius),
      Offset(right, bottom - borderLength),
      bracketPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
