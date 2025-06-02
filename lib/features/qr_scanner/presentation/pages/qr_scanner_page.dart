import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tesoro_regional/core/utils/qr_validator.dart';

class QRScannerPage extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerPage({
    super.key,
    required this.onQRScanned,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late MobileScannerController controller;
  bool _hasPermission = false;
  bool _isScanning = true;
  String? _lastScannedCode;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
    } else {
      final result = await Permission.camera.request();
      setState(() {
        _hasPermission = result.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Escáner QR'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Permiso de cámara requerido',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Para escanear códigos QR y descubrir piezas culturales, necesitamos acceso a tu cámara.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _checkCameraPermission,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Permitir acceso a cámara'),
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
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner QR'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // QR Scanner View
          MobileScanner(
            controller: controller,
            onDetect: _onQRDetected,
          ),

          // Overlay with scanning frame
          _buildScannerOverlay(),

          // Instructions overlay
          Positioned(
            top: 50,
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
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Apunta la cámara hacia un código QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Busca códigos que comiencen con "Ñuble-"',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bottom info panel
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                        label: 'Flash',
                        onPressed: _toggleFlash,
                      ),
                      _ActionButton(
                        icon: Icons.flip_camera_ios,
                        label: 'Voltear',
                        onPressed: _switchCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 16,
          borderLength: 30,
          borderWidth: 8,
          cutOutSize: 250,
        ),
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _lastScannedCode = code;
          _isScanning = false;
        });

        // Validate QR code format
        if (_isValidQrCode(code)) {
          widget.onQRScanned(code);
          Navigator.of(context).pop();
        } else {
          _showInvalidQRDialog(code);
        }
      }
    }
  }

  bool _isValidQrCode(String qrCode) {
    return QRValidator.isValidTesoroRegionalCode(qrCode);
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
    controller.toggleTorch();
  }

  void _switchCamera() {
    controller.switchCamera();
  }

  void _showInvalidQRDialog(String qrCode) {
    final errorMessage = QRValidator.getValidationErrorMessage(qrCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código QR Inválido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Código escaneado:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                qrCode.length > 100 ? '${qrCode.substring(0, 100)}...' : qrCode,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text('Continuar escaneando'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

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
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize < width && cutOutSize < height
        ? cutOutSize
        : (width < height ? width : height) - borderOffset * 2;
    final _cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(_cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw the border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      ..moveTo(_cutOutRect.left, _cutOutRect.top + borderLength)
      ..lineTo(_cutOutRect.left, _cutOutRect.top + borderRadius)
      ..quadraticBezierTo(_cutOutRect.left, _cutOutRect.top, _cutOutRect.left + borderRadius, _cutOutRect.top)
      ..lineTo(_cutOutRect.left + borderLength, _cutOutRect.top)
      ..moveTo(_cutOutRect.right - borderLength, _cutOutRect.top)
      ..lineTo(_cutOutRect.right - borderRadius, _cutOutRect.top)
      ..quadraticBezierTo(_cutOutRect.right, _cutOutRect.top, _cutOutRect.right, _cutOutRect.top + borderRadius)
      ..lineTo(_cutOutRect.right, _cutOutRect.top + borderLength)
      ..moveTo(_cutOutRect.right, _cutOutRect.bottom - borderLength)
      ..lineTo(_cutOutRect.right, _cutOutRect.bottom - borderRadius)
      ..quadraticBezierTo(_cutOutRect.right, _cutOutRect.bottom, _cutOutRect.right - borderRadius, _cutOutRect.bottom)
      ..lineTo(_cutOutRect.right - borderLength, _cutOutRect.bottom)
      ..moveTo(_cutOutRect.left + borderLength, _cutOutRect.bottom)
      ..lineTo(_cutOutRect.left + borderRadius, _cutOutRect.bottom)
      ..quadraticBezierTo(_cutOutRect.left, _cutOutRect.bottom, _cutOutRect.left, _cutOutRect.bottom - borderRadius)
      ..lineTo(_cutOutRect.left, _cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
