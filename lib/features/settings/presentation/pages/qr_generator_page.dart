import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gal/gal.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _keywordController = TextEditingController();

  bool _isGenerating = false;
  String? _errorMessage;

  List<GeneratedQR> _generatedQRs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGeneratedQRs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _loadGeneratedQRs() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    setState(() {
      _generatedQRs = [
        GeneratedQR(
          code: 'Ñuble-plazaAb3X9k',
          keyword: 'plaza',
          generatedAt: DateTime.now().subtract(const Duration(days: 2)),
          displayContent: '${l10n.appName.toUpperCase()}\nTipo: Pieza Cultural\nTítulo: PLAZA\nID: ****Ab',
          actualCode: 'Ñuble-plazaAb3X9k',
        ),
        GeneratedQR(
          code: 'Ñuble-mercadoZ8mN4p',
          keyword: 'mercado',
          generatedAt: DateTime.now().subtract(const Duration(hours: 5)),
          displayContent: '${l10n.appName.toUpperCase()}\nTipo: Pieza Cultural\nTítulo: MERCADO\nID: ****Z8',
          actualCode: 'Ñuble-mercadoZ8mN4p',
        ),
      ];
    });
  }

  void _generateQR() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final keyword = _keywordController.text.trim();

    if (keyword.isEmpty) {
      setState(() {
        _errorMessage = 'La palabra clave no puede estar vacía';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final cleanedWord = keyword.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

      if (cleanedWord.isEmpty) {
        setState(() {
          _errorMessage = 'La palabra debe contener al menos un carácter alfanumérico';
          _isGenerating = false;
        });
        return;
      }

      final suffix = _generateRandomSuffix(6);
      final code = 'Ñuble-$cleanedWord$suffix';

      final qrContent = '${l10n.appName.toUpperCase()}\n'
          'Tipo: Pieza Cultural\n'
          'Título: ${cleanedWord.toUpperCase()}\n'
          'ID: ****${suffix.substring(0, 2)}';

      final newQR = GeneratedQR(
        code: code,
        keyword: cleanedWord,
        generatedAt: DateTime.now(),
        displayContent: qrContent,
        actualCode: code,
      );

      setState(() {
        _generatedQRs.insert(0, newQR);
        _isGenerating = false;
        _keywordController.clear();
      });

      _tabController.animateTo(1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al generar QR: $e';
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qrGenerator),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Generar QR'),
            Tab(text: 'QRs Generados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneratorTab(l10n),
          _buildGeneratedQRsTab(l10n),
        ],
      ),
    );
  }

  Widget _buildGeneratorTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Generador QR para Tesoro Regional',
            'Genera códigos QR personalizados para piezas culturales de la región de Ñuble',
            Icons.qr_code,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _keywordController,
            decoration: const InputDecoration(
              labelText: 'Palabra clave',
              hintText: 'Ej: plaza, mercado, iglesia...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.text_fields),
            ),
            onChanged: (_) {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateQR,
              icon: _isGenerating
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.qr_code_2),
              label: Text(_isGenerating ? 'Generando...' : 'Generar QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneratedQRsTab(AppLocalizations l10n) {
    if (_generatedQRs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay QRs generados',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Genera tu primer QR',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _generatedQRs.length,
      itemBuilder: (context, index) {
        final qr = _generatedQRs[index];
        return _buildQRCard(qr, l10n);
      },
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCard(GeneratedQR qr, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    qr.keyword.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(qr.generatedAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: qr.displayContent.isNotEmpty ? qr.displayContent : qr.code,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  errorStateBuilder: (context, error) {
                    return const Center(
                      child: Text(
                        'Error al generar QR',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyQRToClipboard(qr),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveQR(qr),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Guardar', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQR(GeneratedQR qr) async {
    try {
      if (!await Gal.hasAccess()) {
        final hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se requiere permiso para acceder a la galería'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final qrImage = await _generateQRImage(qr.code);
      final tempDir = await getTemporaryDirectory();
      final fileName = 'QR_${qr.keyword}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(qrImage);
      await Gal.putImage(file.path);
      await file.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR de ${qr.keyword} guardado en galería'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar QR: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generateQRImage(String data) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
    );

    const size = 300.0;
    const imageSize = Size(size, size);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = Colors.white,
    );

    qrPainter.paint(canvas, imageSize);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  void _copyQRToClipboard(GeneratedQR qr) {
    Clipboard.setData(const ClipboardData(text: 'QR copiado - escanea para ver'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR copiado al portapapeles'),
      ),
    );
  }

  String _generateRandomSuffix(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final result = StringBuffer();

    for (var i = 0; i < length; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }

    return result.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Hace un momento';
    }
  }
}

class GeneratedQR {
  final String code;
  final String keyword;
  final DateTime generatedAt;
  final String displayContent;
  final String actualCode;

  GeneratedQR({
    required this.code,
    required this.keyword,
    required this.generatedAt,
    this.displayContent = '',
    this.actualCode = '',
  });
}
