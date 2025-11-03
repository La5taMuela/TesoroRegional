import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';
import 'package:tesoro_regional/core/services/storage/unified_pieces_storage.dart';

class CollectedPiecesPage extends StatefulWidget {
  const CollectedPiecesPage({super.key});

  @override
  State<CollectedPiecesPage> createState() => _CollectedPiecesPageState();
}

class _CollectedPiecesPageState extends State<CollectedPiecesPage> {
  final PiecesStorageService _piecesService = PiecesStorageService();
  final UnifiedPiecesStorage _unifiedStorage = UnifiedPiecesStorage.instance;
  List<String> _collectedPieces = [];
  List<Map<String, dynamic>> _collectedPiecesData = [];
  Map<String, dynamic> _stats = {
    'total': 0,
    'mapPieces': 0,
    'qrPieces': 0,
    'percentage': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadCollectedPieces();
  }

  Future<void> _loadCollectedPieces() async {
    try {
      // Get data from unified storage
      final collectedPiecesData = await _unifiedStorage.getCollectedPiecesData();
      final stats = await _piecesService.getPiecesStats();
      final collectedIds = collectedPiecesData.map((piece) => piece['id'].toString()).toList();

      print('📊 Collected pieces data: $collectedPiecesData');
      print('📊 Collected IDs: $collectedIds');

      setState(() {
        _collectedPieces = collectedIds;
        _collectedPiecesData = collectedPiecesData;
        _stats = stats;
      });
    } catch (e) {
      print('❌ Error loading collected pieces: $e');
    }
  }

  // Helper method to format titles properly
  String _formatTitle(String title) {
    // Convert titles like "provincia-vinicola" to "Provincia Vinicola"
    return title
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Helper method to normalize text for comparison (remove accents)
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u')
        .replaceAll(' ', '')
        .replaceAll('-', '');
  }

  // Helper method to get proper display name for pieces
  String _getPieceDisplayName(Map<String, dynamic> piece, Map<String, dynamic> collectedData) {
    if (collectedData.isNotEmpty && collectedData['title'] != null) {
      // Format the title from collected data
      return _formatTitle(collectedData['title']);
    }

    // If no collected data, format the piece name
    String name = piece['name'] ?? 'Pieza Desconocida';
    if (name.startsWith('Provincia de ')) {
      // Extract just the province name and format it
      String provinceName = name.replaceAll('Provincia de ', '');
      return 'Provincia de $provinceName';
    }

    return name;
  }

  // Helper method to check if a piece is collected using multiple criteria
  bool _isPieceCollected(Map<String, dynamic> piece) {
    final pieceId = piece['id'];

    // Check by exact ID match
    if (_collectedPieces.contains(pieceId)) {
      return true;
    }

    // For QR pieces, also check by province name with normalization
    if (piece['type'] == 'qr') {
      final pieceName = _normalizeText(piece['name'] ?? '');
      final pieceProvinceName = pieceName.replaceAll('provinciade', '');

      for (final collectedData in _collectedPiecesData) {
        final collectedProvince = _normalizeText(collectedData['province']?.toString() ?? '');
        final collectedTitle = _normalizeText(collectedData['title']?.toString() ?? '');

        // Check multiple comparison criteria
        if (collectedProvince.isNotEmpty &&
            (pieceName.contains(collectedProvince) ||
                collectedProvince.contains(pieceProvinceName) ||
                collectedTitle.contains(pieceProvinceName) ||
                pieceProvinceName.contains(collectedProvince))) {
          print('✅ Piece matched: ${piece['name']} with collected: ${collectedData['province']}');
          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Piezas Colectadas'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: _buildPiecesContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.explore,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_stats['total']} de 6 piezas colectadas (${_stats['percentage']}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _stats['percentage'] / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Mapa',
                  _stats['mapPieces'],
                  3,
                  Icons.map,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  'QR Provincias',
                  _stats['qrPieces'],
                  3,
                  Icons.qr_code,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String title,
      int current,
      int total,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$current/$total',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: current == total ? Colors.green : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              current == total ? Colors.green : color,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildPiecesContent() {
    if (_collectedPieces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No has colectado ninguna pieza',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora el mapa o escanea QRs para colectar piezas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/map'),
              icon: const Icon(Icons.map),
              label: const Text('Explorar Mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Provincias Colectadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProvincesGrid(),
          const SizedBox(height: 24),
          const Text(
            'Sitios Descubiertos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMapPiecesGrid(),
        ],
      ),
    );
  }

  Widget _buildProvincesGrid() {
    final qrPieces = PiecesStorageService.allPieces
        .where((piece) => piece['type'] == 'qr')
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: qrPieces.length,
      itemBuilder: (context, index) {
        final piece = qrPieces[index];
        final isCollected = _isPieceCollected(piece);

        // Find matching collected data with better normalization
        final pieceName = _normalizeText(piece['name'] ?? '');
        final pieceProvinceName = pieceName.replaceAll('provinciade', '');

        final collectedData = _collectedPiecesData.firstWhere(
              (data) {
            final collectedProvince = _normalizeText(data['province']?.toString() ?? '');
            return collectedProvince.isNotEmpty &&
                (pieceProvinceName.contains(collectedProvince) ||
                    collectedProvince.contains(pieceProvinceName));
          },
          orElse: () => <String, dynamic>{},
        );

        return _buildProvinceCard(piece, isCollected, collectedData);
      },
    );
  }

  Widget _buildProvinceCard(Map<String, dynamic> piece, bool isCollected, Map<String, dynamic> collectedData) {
    final svgPath = 'assets/nuble_svg/${piece['svgFile']}';
    final displayName = _getPieceDisplayName(piece, collectedData);

    return GestureDetector(
      onTap: () => _showPieceDetails(piece, isCollected),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCollected
                ? HexColor(piece['color'])
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
                  child: SvgPicture.asset(
                    svgPath,
                    colorFilter: ColorFilter.mode(
                      isCollected
                          ? HexColor(piece['color'])
                          : Colors.grey.withOpacity(0.3),
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCollected ? Colors.black87 : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCollected ? Icons.check_circle : Icons.lock,
                          size: 12,
                          color: isCollected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            isCollected ? 'Colectada' : 'Bloqueada',
                            style: TextStyle(
                              fontSize: 10,
                              color: isCollected ? Colors.green : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPiecesGrid() {
    final mapPieces = PiecesStorageService.allPieces
        .where((piece) => piece['type'] == 'map')
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75, // Increased aspect ratio to prevent overflow
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: mapPieces.length,
      itemBuilder: (context, index) {
        final piece = mapPieces[index];
        final isCollected = _isPieceCollected(piece);

        return _buildMapPieceCard(piece, isCollected);
      },
    );
  }

  Widget _buildMapPieceCard(Map<String, dynamic> piece, bool isCollected) {
    return GestureDetector(
      onTap: () => _showPieceDetails(piece, isCollected),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCollected
                ? HexColor(piece['color'])
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: isCollected
                        ? HexColor(piece['color']).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(piece['siteType']),
                    color: isCollected
                        ? HexColor(piece['color'])
                        : Colors.grey.withOpacity(0.5),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      piece['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCollected ? Colors.black87 : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCollected ? Icons.check_circle : Icons.lock,
                          size: 12,
                          color: isCollected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            isCollected ? 'Descubierto' : 'Bloqueado',
                            style: TextStyle(
                              fontSize: 10,
                              color: isCollected ? Colors.green : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'plaza':
        return Icons.park;
      case 'market':
        return Icons.store;
      case 'religious':
        return Icons.church;
      case 'museum':
        return Icons.museum;
      case 'historical':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  void _showPieceDetails(Map<String, dynamic> piece, bool isCollected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCollected ? Icons.check_circle : Icons.lock,
              color: isCollected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                piece['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (piece['type'] == 'qr') ...[
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/nuble_svg/${piece['svgFile']}',
                    colorFilter: ColorFilter.mode(
                      isCollected
                          ? HexColor(piece['color'])
                          : Colors.grey.withOpacity(0.3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: isCollected
                        ? HexColor(piece['color']).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(piece['siteType']),
                    color: isCollected
                        ? HexColor(piece['color'])
                        : Colors.grey.withOpacity(0.5),
                    size: 40,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Tipo: ${piece['type'] == 'qr' ? 'Provincia (QR)' : 'Sitio Cultural (Mapa)'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(piece['description']),
            const SizedBox(height: 16),
            if (!isCollected) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        piece['type'] == 'qr'
                            ? 'Escanea el código QR de esta provincia para desbloquearla'
                            : 'Visita este lugar para desbloquearlo',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (piece['type'] == 'qr' && !isCollected)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/qr-scanner');
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR'),
            ),
          if (piece['type'] == 'map' && !isCollected)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/map');
              },
              icon: const Icon(Icons.map),
              label: const Text('Ir al Mapa'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
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
