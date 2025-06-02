import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/location/location_service.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/presentation/providers/puzzle_providers.dart';
import 'package:tesoro_regional/features/puzzle/presentation/state/puzzle_state.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/map_controls.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/piece_info_sheet.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final LocationService _locationService = LocationServiceImpl();
  CulturalPiece? _selectedPiece;

  // Mock center position for Ñuble region
  final double _centerLatitude = -36.6062;
  final double _centerLongitude = -72.1025;

  @override
  void initState() {
    super.initState();
    _loadNearbyPieces();
  }

  Future<void> _loadNearbyPieces() async {
    await Future.delayed(const Duration(seconds: 1));
    ref.read(puzzleStateProvider.notifier).loadPuzzleData();
  }

  void _onPieceSelected(CulturalPiece piece) {
    setState(() {
      _selectedPiece = piece;
    });
  }

  void _zoomIn() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.zoomInDevelopment),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _zoomOut() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.zoomOutDevelopment),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _locateUser() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    try {
      final locationData = await _locationService.getCurrentLocation();
      if (locationData != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.locationFound(
                locationData.latitude.toStringAsFixed(4),
                locationData.longitude.toStringAsFixed(4),
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locationError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final puzzleState = ref.watch(puzzleStateProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: l10n == null ? const Text("Cultural Map") : Text(l10n.culturalMap),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Stack(
          children: [
            // Simplified map placeholder
            Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      l10n == null ? "Cultural Map" : l10n.culturalMapTitle,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n == null ? "Map Center" : l10n.mapCenter(_centerLatitude.toStringAsFixed(4), _centerLongitude.toStringAsFixed(4)),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    if (puzzleState is PuzzleLoaded) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          l10n == null ? "Pieces Discovered" : l10n.piecesDiscoveredCount(puzzleState.collectedPieces.length),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (puzzleState.collectedPieces.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            _onPieceSelected(puzzleState.collectedPieces.first);
                          },
                          child: Text(l10n == null ? "View Example Piece" : l10n.viewExamplePiece),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Map controls
            Positioned(
              top: 16,
              right: 16,
              child: MapControls(
                onZoomIn: _zoomIn,
                onZoomOut: _zoomOut,
                onLocateMe: _locateUser,
              ),
            ),

            // Piece info sheet
            if (_selectedPiece != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy > 300) {
                      setState(() {
                        _selectedPiece = null;
                      });
                    }
                  },
                  child: PieceInfoSheet(
                    piece: _selectedPiece!,
                    onUnlock: _selectedPiece!.isUnlocked ? null : () {
                      if (mounted) {
                        final l10n = AppLocalizations.of(context);
                        if (l10n == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pieceUnlocked),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _selectedPiece = null;
                        });
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
