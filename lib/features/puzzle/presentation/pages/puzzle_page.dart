import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/puzzle/presentation/providers/puzzle_providers.dart';
import 'package:tesoro_regional/features/puzzle/presentation/state/puzzle_state.dart';
import 'package:tesoro_regional/features/qr_scanner/presentation/widgets/qr_scanner_widget.dart';
import 'package:tesoro_regional/core/widgets/error_view.dart';
import 'package:tesoro_regional/core/widgets/loading_view.dart';
import 'package:tesoro_regional/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:tesoro_regional/core/utils/qr_validator.dart';

class PuzzlePage extends ConsumerStatefulWidget {
  const PuzzlePage({super.key});

  @override
  ConsumerState<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends ConsumerState<PuzzlePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(puzzleStateProvider.notifier).loadPuzzleData());
  }

  Future<void> _handleQRScanned(String qrCode) async {
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
              Text('Verificando código QR...'),
            ],
          ),
        ),
      );

      // Try to collect the piece
      final result = await ref.read(puzzleStateProvider.notifier).collectPieceByQr(qrCode);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (result != null) {
          // Success - show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¡Pieza Descubierta!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Has descubierto: ${result.getLocalizedDescription('es').split('.').first}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Categoría: ${result.category.name}',
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
                    child: Text(
                      QRValidator.isStructuredFormat(qrCode)
                          ? 'QR Estructurado Reconocido'
                          : 'QR Tradicional Reconocido',
                      style: const TextStyle(
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('¡Genial!'),
                ),
              ],
            ),
          );
        } else {
          // Failed - show error dialog with more details
          final isStructured = QRValidator.isStructuredFormat(qrCode);
          final keyword = QRValidator.extractKeyword(qrCode);

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Código QR No Reconocido'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text('Tipo de QR: ${isStructured ? 'Estructurado' : 'Tradicional'}'),
                  if (keyword != null) ...[
                    const SizedBox(height: 8),
                    Text('Palabra clave detectada: $keyword'),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Este código QR es válido pero no se encontró una pieza cultural correspondiente en la base de datos.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Verifica que el QR corresponda a una ubicación cultural de Ñuble.',
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
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar QR: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          onQRScanned: _handleQRScanned,
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
          title: const Text('Puzzle Cultural'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => _openQRScanner(),
              tooltip: 'Escanear QR',
            ),
          ],
        ),
        body: _buildBody(puzzleState),
      ),
    );
  }

  Widget _buildBody(PuzzleState state) {
    if (state is PuzzleInitial || state is PuzzleLoading) {
      return const LoadingView(message: 'Cargando puzzle...');
    } else if (state is PuzzleLoaded) {
      return Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.extension, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Progreso del Puzzle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${state.collectedPieces.length} piezas',
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
                    value: state.completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.completionPercentage.toStringAsFixed(1)}% completado',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Categories
          if (state.categories.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final isSelected = category.id == state.selectedCategoryId;

                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: isSelected ? 8 : 2,
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      child: InkWell(
                        onTap: () => ref.read(puzzleStateProvider.notifier).selectCategory(category.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getCategoryIcon(category.name),
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[600],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Pieces grid
          Expanded(
            child: state.collectedPieces.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No has descubierto piezas aún',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escanea códigos QR que comiencen con "Ñuble-" para descubrir piezas culturales.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _openQRScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Escanear QR'),
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
              itemCount: state.collectedPieces.length,
              itemBuilder: (context, index) {
                final piece = state.collectedPieces[index];
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
                            color: Colors.grey[300],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: piece.imageUrl != null
                              ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              piece.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          )
                              : const Center(
                            child: Icon(Icons.image, size: 50, color: Colors.grey),
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
                                piece.getLocalizedDescription('es').split('.').first,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                piece.category.name,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    piece.isUnlocked ? Icons.lock_open : Icons.lock,
                                    size: 14,
                                    color: piece.isUnlocked ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    piece.isUnlocked ? 'Desbloqueado' : 'Bloqueado',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: piece.isUnlocked ? Colors.green : Colors.grey,
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

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'monumentos':
        return Icons.account_balance;
      case 'gastronomía':
        return Icons.restaurant;
      case 'historia':
        return Icons.history_edu;
      case 'artesanía':
        return Icons.palette;
      case 'tradiciones':
        return Icons.celebration;
      default:
        return Icons.category;
    }
  }
}
