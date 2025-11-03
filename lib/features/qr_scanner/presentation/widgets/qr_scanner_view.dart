import 'package:flutter/material.dart';
import 'package:tesoro_regional/features/qr_scanner/presentation/pages/qr_scanner_page.dart';

import '../../domain/entities/qr_piece.dart';

class QRScannerView extends StatelessWidget {
  final Function(QRPiece?) onPieceScanned;

  const QRScannerView({super.key, required this.onPieceScanned});

  @override
  Widget build(BuildContext context) {
    return QRScannerPage(onPieceScanned: onPieceScanned);
  }
}
