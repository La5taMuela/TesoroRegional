import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/puzzle/presentation/providers/puzzle_providers.dart';
import 'package:tesoro_regional/features/puzzle/presentation/state/puzzle_state.dart';
import 'package:tesoro_regional/core/widgets/error_view.dart';
import 'package:tesoro_regional/core/widgets/loading_view.dart';
import 'package:tesoro_regional/features/qr_scanner/presentation/widgets/qr_scanner_view.dart';
import 'package:tesoro_regional/features/qr_scanner/domain/entities/qr_piece.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';

class PuzzlePage extends ConsumerStatefulWidget {
  const PuzzlePage({super.key});

  @override
  ConsumerState<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends ConsumerState<PuzzlePage> {
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
        .replaceAll('ü', 'u');
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(puzzleStateProvider.notifier).loadPuzzleData());
  }

  void _handleQRPieceScanned(QRPiece? qrPiece) async {
    Navigator.of(context).pop(); // Close scanner

    if (qrPiece == null) {
      _showErrorDialog('No se pudo procesar el código QR');
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Actualizando progreso...'),
            ],
          ),
        ),
      );

      // Refresh puzzle data to show the new piece
      await ref.read(puzzleStateProvider.notifier).refreshAfterQRScan();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success dialog with image
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¡Pieza Descubierta!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mostrar imagen si está disponible
                if (qrPiece.imageUrl != null)
                  Container(
                    height: 120,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(qrPiece.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.celebration, size: 64, color: Colors.green),

                const SizedBox(height: 16),
                Text(
                  'Has descubierto: ${qrPiece.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Provincia: ${qrPiece.province}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Pieza agregada a tu colección',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/collected-pieces');
                },
                child: const Text('Ver Colección'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('¡Genial!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        _showErrorDialog('Error al actualizar progreso: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 12),
            const Text(
              'Verifica que el QR corresponda a una provincia de Ñuble válida.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _openQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerView(
          onPieceScanned: _handleQRPieceScanned,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puzzleState = ref.watch(puzzleStateProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Puzzle Cultural - Provincias QR'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: _buildBody(puzzleState),
      ),
    );
  }

  Widget _buildBody(PuzzleState state) {
    if (state is PuzzleInitial || state is PuzzleLoading) {
      return const LoadingView(message: 'Cargando puzzle...');
    } else if (state is PuzzleLoaded) {
      // Filtrar solo las piezas QR (no las del mapa)
      final qrPieces = state.collectedPieces.where((piece) {
        // Verificar si la pieza es de tipo QR basándose en el ID o propiedades
        return !_isMapPiece(piece.id.toString());
      }).toList();

      // Calcular estadísticas solo para piezas QR
      final totalQRPieces = PiecesStorageService.allPieces
          .where((piece) => piece['type'] == 'qr')
          .length;
      final qrCompletionPercentage = totalQRPieces > 0
          ? (qrPieces.length / totalQRPieces * 100)
          : 0.0;

      return Column(
        children: [
          // Progress bar - solo para piezas QR
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Progreso de Provincias QR',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${qrPieces.length} provincias',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: qrCompletionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${qrCompletionPercentage.toStringAsFixed(1)}% de provincias completadas',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Quick action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openQRScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Escanear QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/collected-pieces'),
                    icon: const Icon(Icons.collections_bookmark),
                    label: const Text('Ver Colección'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info card about QR pieces
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provincias de Ñuble',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Escanea códigos QR para descubrir las provincias de la región de Ñuble',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pieces grid or empty state - solo piezas QR
          Expanded(
            child: qrPieces.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No has descubierto provincias aún',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escanea códigos QR de las provincias de Ñuble para comenzar tu colección.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _openQRScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Escanear QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: qrPieces.length,
              itemBuilder: (context, index) {
                final piece = qrPieces[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: piece.imageUrl != null
                              ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.asset(
                              piece.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.landscape, size: 50, color: Colors.purple),
                                );
                              },
                            ),
                          )
                              : const Center(
                            child: Icon(Icons.landscape, size: 50, color: Colors.purple),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTitle(piece.title),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Provincia ${_formatTitle(piece.province)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.landscape,
                                    size: 14,
                                    color: Colors.purple,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Provincia de Ñuble',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.purple.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
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
              },
            ),
          ),
        ],
      );
    } else if (state is PuzzleError) {
      return ErrorView(
        message: state.message,
        onRetry: () => ref.read(puzzleStateProvider.notifier).loadPuzzleData(),
      );
    }

    return const SizedBox.shrink();
  }

  // Helper method to identify if a piece is from the map
  bool _isMapPiece(String pieceId) {
    // Las piezas del mapa tienen IDs que empiezan con 'map_'
    return pieceId.startsWith('map_');
  }
}
