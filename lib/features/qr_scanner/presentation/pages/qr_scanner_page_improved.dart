import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'qr_scanner_page.dart';
import 'web_qr_scanner_page.dart';

class QRScannerPageImproved extends ConsumerWidget {
  final Function(dynamic)? onPieceScanned;

  const QRScannerPageImproved({super.key, this.onPieceScanned});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar implementación específica según la plataforma
    if (kIsWeb) {
      return WebQRScannerPage(onPieceScanned: onPieceScanned);
    } else {
      return QRScannerPage(onPieceScanned: onPieceScanned);
    }
  }
}
