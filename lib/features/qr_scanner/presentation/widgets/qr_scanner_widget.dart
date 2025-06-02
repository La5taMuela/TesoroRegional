import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
class QrScannerWidget extends StatelessWidget {
  final Function(String) onDetect;

  const QrScannerWidget({Key? key, required this.onDetect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              onDetect(barcode.rawValue!);
            }
          }
        },
      ),
      appBar: AppBar(
        title: Text(l10n?.scanQR ?? 'Escanear QR'),
      ),
    );
  }
}
