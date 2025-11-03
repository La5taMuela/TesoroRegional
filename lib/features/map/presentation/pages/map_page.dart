import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';
import 'package:tesoro_regional/core/services/location/location_service.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';
import 'package:tesoro_regional/core/services/storage/unified_pieces_storage.dart';
import 'package:tesoro_regional/features/map/domain/entities/strategic_point.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/map_controls.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/map_layers_menu.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/piece_info_sheet.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/progress_menu.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  final PiecesStorageService _piecesService = PiecesStorageService();
  final UnifiedPiecesStorage _unifiedStorage = UnifiedPiecesStorage.instance;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _hasInternetConnection = true;

  final List<StrategicPoint> _strategicPoints = [
    const StrategicPoint(
      id: '1',
      name: 'Plaza de Armas de Chillán',
      description: 'Corazón histórico de la ciudad',
      latitude: -36.60668,
      longitude: -72.10332,
      iconUrl: 'assets/icons/plaza_icon.png',
      puzzlePieceId: 'map_plaza_chillan',
      activationRadius: 100.0,
    ),
    const StrategicPoint(
      id: '2',
      name: 'Mercado de Chillán',
      description: 'Mercado tradicional con artesanías y comida local',
      latitude: -36.610434,
      longitude: -72.101293,
      iconUrl: 'assets/icons/market_icon.png',
      puzzlePieceId: 'map_mercado_chillan',
    ),
    const StrategicPoint(
      id: '3',
      name: 'Catedral de Chillán',
      description: 'Icono arquitectónico de la ciudad',
      latitude: -36.606812,
      longitude: -72.102354,
      iconUrl: 'assets/icons/cathedral_icon.png',
      puzzlePieceId: 'map_catedral_chillan',
    ),
    const StrategicPoint(
      id: '4',
      name: 'Inacap Chillán',
      description: 'Instituto profesional ubicado en Chillán',
      latitude: -36.593860,
      longitude: -72.103804,
      iconUrl: 'assets/icons/inacap.png',
      puzzlePieceId: 'map_inacap_chillan',
    )
  ];

  StrategicPoint? _activePoint;
  bool _isLoading = true;
  LatLng? _currentPosition;
  bool _mapReady = false;
  static const String _mapPositionKey = 'map_position';
  static const String _mapZoomKey = 'map_zoom';
  double _savedZoom = 15.0;
  LatLng? _savedPosition;
  String _currentMapLayer =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  bool _showProgressMenu = false;
  bool _showFullScreenMenu = false;
  bool _showLayersMenu = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection().then((hasInternet) {
      if (hasInternet) {
        _loadSavedProgress();
        _initLocation();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _preloadImages();
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult != ConnectivityResult.none;
    setState(() => _hasInternetConnection = hasInternet);

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
          setState(
                  () => _hasInternetConnection = result != ConnectivityResult.none);
          if (!_hasInternetConnection) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No hay conexión a internet'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });

    return hasInternet;
  }

  Future<void> _loadSavedProgress() async {
    try {
      // Cargar progreso desde el sistema unificado de piezas
      for (final point in _strategicPoints) {
        if (point.puzzlePieceId != null) {
          final isCollected =
          await _piecesService.isPieceCollected(point.puzzlePieceId!);
          if (isCollected) {
            final index = _strategicPoints.indexWhere((p) => p.id == point.id);
            if (index != -1) {
              _strategicPoints[index] = point.copyWith(isUnlocked: true);
            }
          }
        }
      }

      // También mantener compatibilidad con SharedPreferences para piezas ya guardadas
      try {
        final prefs = getIt<SharedPreferences>();
        for (final point in _strategicPoints) {
          final isUnlocked = prefs.getBool('point_${point.id}') ?? false;
          if (isUnlocked && !point.isUnlocked) {
            final index = _strategicPoints.indexWhere((p) => p.id == point.id);
            if (index != -1) {
              _strategicPoints[index] = point.copyWith(isUnlocked: true);
              // Migrar a nuevo sistema
              if (point.puzzlePieceId != null) {
                await _savePieceToUnifiedSystem(point);
              }
            }
          }
        }
      } catch (e) {
        print(
            '⚠️ SharedPreferences not available, using unified storage only: $e');
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('❌ Error loading saved progress: $e');
    }
  }

  Future<void> _savePieceToUnifiedSystem(StrategicPoint point) async {
    try {
      if (point.puzzlePieceId == null) return;

      // Use the PiecesStorageService collectPiece method instead
      final success = await _piecesService.collectPiece(point.puzzlePieceId!);

      if (success) {
        print('✅ Piece saved to unified system: ${point.name}');
      } else {
        print('❌ Failed to save piece to unified system: ${point.name}');
      }
    } catch (e) {
      print('❌ Error saving piece to unified system: $e');
    }
  }

  String _getSiteTypeFromPoint(StrategicPoint point) {
    if (point.name.toLowerCase().contains('plaza')) return 'plaza';
    if (point.name.toLowerCase().contains('mercado')) return 'market';
    if (point.name.toLowerCase().contains('catedral')) return 'religious';
    if (point.name.toLowerCase().contains('inacap')) return 'educational';
    return 'cultural';
  }

  Future<void> _saveProgress(String pointId) async {
    try {
      final prefs = getIt<SharedPreferences>();
      await prefs.setBool('point_$pointId', true);
    } catch (e) {
      print('⚠️ Could not save to SharedPreferences: $e');
    }
  }

  Future<void> _preloadImages() async {
    final uniqueIcons = _strategicPoints.map((p) => p.iconUrl).toSet();
    for (final icon in uniqueIcons) {
      try {
        await precacheImage(AssetImage(icon), context);
      } catch (e) {
        print('Warning: Could not preload image $icon: $e');
      }
    }
  }

  Future<void> _initLocation() async {
    try {
      // Load saved position first
      await _loadSavedMapPosition();

      // Try to get current location with timeout
      try {
        final locationService = getIt<LocationService>();
        final locationData = await locationService
            .getCurrentLocation()
            .timeout(const Duration(seconds: 10));

        if (locationData != null) {
          setState(() {
            _currentPosition =
                LatLng(locationData.latitude, locationData.longitude);
          });

          // If no saved position, use current location
          if (_savedPosition == null) {
            _savedPosition = _currentPosition;
            _savedZoom = 15.0;
            await _saveMapPosition(_currentPosition!, _savedZoom);
          }

          if (_mapReady) {
            _mapController.move(
                _savedPosition ?? _currentPosition!, _savedZoom);
          }
        }
      } on TimeoutException {
        print('⚠️ Location request timed out');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
              Text('Location request timed out. Using default position.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        print('⚠️ LocationService error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not get location: ${e.toString()}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Location error: $e');
      // Fallback to saved position or default location
      _savedPosition ??= const LatLng(-36.6066, -72.1034);
      if (_mapReady) {
        _mapController.move(_savedPosition!, _savedZoom);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSavedMapPosition() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final lat = prefs.getDouble('${_mapPositionKey}_lat');
      final lng = prefs.getDouble('${_mapPositionKey}_lng');
      final zoom = prefs.getDouble(_mapZoomKey) ?? 15.0;

      if (lat != null && lng != null) {
        _savedPosition = LatLng(lat, lng);
        _savedZoom = zoom;
      }
    } catch (e) {
      print('⚠️ Could not load saved map position: $e');
    }
  }

  Future<void> _saveMapPosition(LatLng position, double zoom) async {
    try {
      final prefs = getIt<SharedPreferences>();
      await prefs.setDouble('${_mapPositionKey}_lat', position.latitude);
      await prefs.setDouble('${_mapPositionKey}_lng', position.longitude);
      await prefs.setDouble(_mapZoomKey, zoom);
    } catch (e) {
      print('⚠️ Could not save map position: $e');
    }
  }

  bool _isPointInRange(StrategicPoint point) {
    if (_currentPosition == null) return false;

    const distance = Distance();
    final meters = distance(
      LatLng(point.latitude, point.longitude),
      _currentPosition!,
    );

    return meters <= point.activationRadius;
  }

  Future<void> _unlockPoint(StrategicPoint point) async {
    try {
      // Verificar si ya está desbloqueada
      if (point.isUnlocked) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${point.name} ya está desbloqueada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      setState(() {
        final index = _strategicPoints.indexWhere((p) => p.id == point.id);
        if (index != -1) {
          _strategicPoints[index] = point.copyWith(isUnlocked: true);
        }
      });

      // Guardar en SharedPreferences (compatibilidad)
      await _saveProgress(point.id);

      // Guardar en el sistema unificado de piezas
      await _savePieceToUnifiedSystem(point);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(child: Text('¡Has desbloqueado ${point.name}!')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Ver Progreso',
              textColor: Colors.white,
              onPressed: () {
                context.go('/collected-pieces');
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error unlocking point: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al desbloquear la pieza'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPointInfo(StrategicPoint point) {
    if (!_isPointInRange(point) && !point.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Debes estar a menos de ${point.activationRadius.toInt()}m de ${point.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _activePoint = point;
      // Cerrar todos los otros menús
      _showLayersMenu = false;
      _showProgressMenu = false;
      _showFullScreenMenu = false;
    });
  }

  void _closeAllMenus() {
    setState(() {
      _showLayersMenu = false;
      _showProgressMenu = false;
      _showFullScreenMenu = false;
      _activePoint = null;
    });
  }

  bool get _shouldShowMapControls {
    return !_showLayersMenu &&
        !_showProgressMenu &&
        !_showFullScreenMenu &&
        _activePoint == null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    if (!_hasInternetConnection) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de Ñuble'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 50, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Se requiere conexión a internet para acceder al mapa',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Por favor, verifica tu conexión a internet y vuelve a intentarlo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar conexión'),
                  onPressed: () async {
                    final result = await Connectivity().checkConnectivity();
                    setState(() {
                      _hasInternetConnection =
                          result != ConnectivityResult.none;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de Ñuble'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () {
                setState(() {
                  _showFullScreenMenu = !_showFullScreenMenu;
                  if (_showFullScreenMenu) {
                    _showLayersMenu = false;
                    _showProgressMenu = false;
                    _activePoint = null;
                  }
                });
              },
              tooltip: 'Vista completa',
            ),
            IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () {
                setState(() {
                  _showLayersMenu = !_showLayersMenu;
                  if (_showLayersMenu) {
                    _showProgressMenu = false;
                    _showFullScreenMenu = false;
                    _activePoint = null;
                  }
                });
              },
              tooltip: 'Cambiar capa del mapa',
            ),
          ],
        ),
        body: Stack(
          children: [
            // Mapa principal
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _savedPosition ?? const LatLng(-36.6066, -72.1034),
                zoom: _savedZoom,
                minZoom: 10.0,
                maxZoom: 18.0,
                onMapReady: () {
                  setState(() => _mapReady = true);
                  final initialPosition = _savedPosition ??
                      _currentPosition ??
                      const LatLng(-36.6066, -72.1034);
                  _mapController.move(initialPosition, _savedZoom);
                },
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    _saveMapPosition(position.center!, position.zoom!);
                  }
                },
                onTap: (tapPosition, point) {
                  // Cerrar menús al tocar el mapa
                  if (_showLayersMenu || _showProgressMenu || _activePoint != null) {
                    _closeAllMenus();
                  }
                },
                interactiveFlags:
                InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              children: [
                TileLayer(
                  urlTemplate: _currentMapLayer,
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                if (_mapReady)
                  MarkerLayer(
                    markers: _strategicPoints.map((point) {
                      return Marker(
                        point: LatLng(point.latitude, point.longitude),
                        width: 40,
                        height: 40,
                        builder: (ctx) => GestureDetector(
                          onTap: () => _showPointInfo(point),
                          child: Stack(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: point.isUnlocked
                                      ? Colors.green
                                      : Colors.blue,
                                  shape: BoxShape.circle,
                                  border:
                                  Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getIconForSiteType(
                                      _getSiteTypeFromPoint(point)),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              if (point.isUnlocked)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 30,
                        height: 30,
                        builder: (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                  ],
                  alignment: AttributionAlignment.bottomRight,
                ),
              ],
            ),

            // Indicador de progreso en la esquina superior izquierda
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Descubiertos: ${_strategicPoints.where((s) => s.isUnlocked).length}/${_strategicPoints.length}',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menú de capas
            if (_showLayersMenu)
              Positioned(
                top: 70,
                right: isLargeScreen ? 40 : 20,
                child: MapLayersMenu(
                  onLayerSelected: (url) {
                    setState(() {
                      _currentMapLayer = url;
                      _showLayersMenu = false;
                    });
                  },
                  onClose: () => setState(() => _showLayersMenu = false),
                ),
              ),

            // Menú de progreso
            if (_showProgressMenu)
              Positioned(
                top: 70,
                right: isLargeScreen ? 40 : 20,
                child: ProgressMenu(
                  points: _strategicPoints,
                  onClose: () => setState(() => _showProgressMenu = false),
                  onPointSelected: (point) {
                    setState(() {
                      _activePoint = point;
                      _showProgressMenu = false;
                    });
                    _mapController.move(
                      LatLng(point.latitude, point.longitude),
                      16.0, // Zoom más cercano al seleccionar un punto
                    );
                  },
                ),
              ),

            // Vista de pantalla completa
            if (_showFullScreenMenu)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text('Sitios Culturales'),
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _showFullScreenMenu = false),
                        ),
                        elevation: 1,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                          child: GridView.builder(
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isLargeScreen ? 2 : 1,
                              childAspectRatio: isLargeScreen ? 3.5 : 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _strategicPoints.length,
                            itemBuilder: (ctx, index) {
                              final point = _strategicPoints[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() {
                                      _activePoint = point;
                                      _showFullScreenMenu = false;
                                    });
                                    _mapController.move(
                                      LatLng(point.latitude, point.longitude),
                                      16.0,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: point.isUnlocked
                                                ? Colors.green
                                                : Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            point.isUnlocked
                                                ? Icons.check_circle
                                                : Icons.lock,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                point.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                point.description,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (point.isUnlocked)
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 28,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Controles del mapa (solo cuando no hay menús abiertos)
            if (_shouldShowMapControls)
              Positioned(
                bottom: 120,
                right: 16,
                child: MapControls(
                  onLocationUpdated: (latLng) {
                    setState(() => _currentPosition = latLng);
                    if (_mapReady) {
                      _mapController.move(latLng, _mapController.zoom);
                    }
                  },
                  onZoomChanged: (delta) {
                    if (_mapReady) {
                      _mapController.move(
                          _mapController.center, _mapController.zoom + delta);
                    }
                  },
                ),
              ),

            // Hoja de información de la pieza
            if (_activePoint != null)
              PieceInfoSheet(
                point: _activePoint!,
                onUnlock: () => _unlockPoint(_activePoint!),
                isInRange: _isPointInRange(_activePoint!),
                distance: _currentPosition != null
                    ? const Distance()
                    .distance(
                  LatLng(_activePoint!.latitude, _activePoint!.longitude),
                  _currentPosition!,
                )
                    .toStringAsFixed(0)
                    : '--',
                onClose: () => setState(() => _activePoint = null),
              ),

            // Indicador de carga
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSiteType(String siteType) {
    switch (siteType) {
      case 'plaza':
        return Icons.park;
      case 'market':
        return Icons.store;
      case 'religious':
        return Icons.church;
      case 'educational':
        return Icons.school;
      default:
        return Icons.place;
    }
  }
}
