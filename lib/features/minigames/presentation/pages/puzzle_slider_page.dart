import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class PuzzleSliderPage extends StatefulWidget {
  const PuzzleSliderPage({super.key});

  @override
  State<PuzzleSliderPage> createState() => _PuzzleSliderPageState();
}

class _PuzzleSliderPageState extends State<PuzzleSliderPage> {
  List<int> _tiles = [];
  int _gridSize = 3; // 3x3 grid
  int _emptyIndex = 8; // Posición del espacio vacío
  int _moves = 0;
  bool _isCompleted = false;
  late Stopwatch _stopwatch;
  Set<int> _completedPuzzles = {};
  bool _showPuzzleSelector = true;
  bool _imagesLoaded = false;

  // Imágenes locales de lugares culturales de Ñuble
  final List<Map<String, dynamic>> _puzzleImages = [
    {
      'es': {
        'title': 'Plaza de Armas de Chillán',
        'description': 'Corazón de la ciudad reconstruida',
      },
      'en': {
        'title': 'Chillán Main Square',
        'description': 'Heart of the rebuilt city',
      },
      'path': 'assets/images/puzzle_slider/Plaza de Armas de Chillán.jpg',
    },
    {
      'es': {
        'title': 'Catedral de San Bartolomé',
        'description': 'Símbolo de la reconstrucción',
      },
      'en': {
        'title': 'San Bartolomé Cathedral',
        'description': 'Symbol of reconstruction',
      },
      'path': 'assets/images/puzzle_slider/Catedral de San Bartolomé.jpg',
    },
    {
      'es': {
        'title': 'Nevados de Chillán',
        'description': 'Complejo volcánico y centro de esquí',
      },
      'en': {
        'title': 'Nevados de Chillán',
        'description': 'Volcanic complex and ski resort',
      },
      'path': 'assets/images/puzzle_slider/Nevados de Chillán.jpg',
    },
    {
      'es': {
        'title': 'Mercado de Chillán',
        'description': 'Centro gastronómico tradicional',
      },
      'en': {
        'title': 'Chillán Market',
        'description': 'Traditional gastronomic center',
      },
      'path': 'assets/images/puzzle_slider/Mercado de Chillán.jpg',
    },
    {
      'es': {
        'title': 'Termas de Chillán',
        'description': 'Aguas termales naturales',
      },
      'en': {
        'title': 'Chillán Hot Springs',
        'description': 'Natural thermal waters',
      },
      'path': 'assets/images/puzzle_slider/Termas de Chillán.jpg',
    },
    {
      'es': {
        'title': 'Viñedos del Valle del Itata',
        'description': 'Tradición vitivinícola ancestral',
      },
      'en': {
        'title': 'Itata Valley Vineyards',
        'description': 'Ancestral winemaking tradition',
      },
      'path': 'assets/images/puzzle_slider/Viñedos del Valle del Itata.jpg',
    },
  ];

  // Precarga de imágenes
  final Map<String, Image> _cachedImages = {};
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _loadCompletedPuzzles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImages();
  }

  void _precacheImages() {
    if (_imagesLoaded) return;

    for (var puzzle in _puzzleImages) {
      final imagePath = puzzle['path'] as String;
      final image = Image.asset(imagePath);
      _cachedImages[imagePath] = image;
      precacheImage(AssetImage(imagePath), context);
    }

    _imagesLoaded = true;
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _loadCompletedPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList('completed_puzzles') ?? [];
    setState(() {
      _completedPuzzles = completedList.map((e) => int.parse(e)).toSet();
    });
  }

  Future<void> _saveCompletedPuzzle(int puzzleIndex) async {
    final prefs = await SharedPreferences.getInstance();
    _completedPuzzles.add(puzzleIndex);
    final completedList = _completedPuzzles.map((e) => e.toString()).toList();
    await prefs.setStringList('completed_puzzles', completedList);
  }

  void _selectPuzzle(int index) {
    setState(() {
      _currentImageIndex = index;
      _showPuzzleSelector = false;
    });
    _initializePuzzle();
  }

  void _goToPuzzleSelector() {
    setState(() {
      _showPuzzleSelector = true;
    });
  }

  void _initializePuzzle() {
    _stopwatch.reset();

    // Si el puzzle ya está completado, mostrar como completado
    if (_completedPuzzles.contains(_currentImageIndex)) {
      _tiles = List.generate(_gridSize * _gridSize - 1, (index) => index);
      _tiles.add(-1);
      _emptyIndex = _gridSize * _gridSize - 1;
      setState(() {
        _moves = 0;
        _isCompleted = true;
      });
      _stopwatch.stop();
    } else {
      // Inicializar tiles en orden correcto
      _tiles = List.generate(_gridSize * _gridSize - 1, (index) => index);
      _tiles.add(-1); // -1 representa el espacio vacío
      _emptyIndex = _gridSize * _gridSize - 1;

      // Mezclar el puzzle
      _shufflePuzzle();

      setState(() {
        _moves = 0;
        _isCompleted = false;
      });
      _stopwatch.start();
    }
  }

  void _shufflePuzzle() {
    final random = Random();

    // Realizar muchos movimientos aleatorios válidos para mezclar bien
    for (int i = 0; i < 2000; i++) {
      final validMoves = _getValidMoves();
      if (validMoves.isNotEmpty) {
        final randomMove = validMoves[random.nextInt(validMoves.length)];
        _moveTileInternal(randomMove);
      }
    }
  }

  // Movimiento interno para mezclar (sin contar movimientos)
  void _moveTileInternal(int tileIndex) {
    final validMoves = _getValidMoves();
    if (!validMoves.contains(tileIndex)) return;

    // Intercambiar tile con espacio vacío
    _tiles[_emptyIndex] = _tiles[tileIndex];
    _tiles[tileIndex] = -1;
    _emptyIndex = tileIndex;
  }

  List<int> _getValidMoves() {
    final validMoves = <int>[];
    final row = _emptyIndex ~/ _gridSize;
    final col = _emptyIndex % _gridSize;

    // Arriba
    if (row > 0) validMoves.add(_emptyIndex - _gridSize);
    // Abajo
    if (row < _gridSize - 1) validMoves.add(_emptyIndex + _gridSize);
    // Izquierda
    if (col > 0) validMoves.add(_emptyIndex - 1);
    // Derecha
    if (col < _gridSize - 1) validMoves.add(_emptyIndex + 1);

    return validMoves;
  }

  void _moveTile(int tileIndex, bool countMove) {
    if (!_getValidMoves().contains(tileIndex) || _isCompleted) return;

    setState(() {
      // Intercambiar tile con espacio vacío
      _tiles[_emptyIndex] = _tiles[tileIndex];
      _tiles[tileIndex] = -1;
      _emptyIndex = tileIndex;

      if (countMove) {
        _moves++;
        _checkCompletion();
      }
    });
  }

  void _checkCompletion() {
    bool completed = true;
    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i) {
        completed = false;
        break;
      }
    }

    if (completed && !_isCompleted) {
      _stopwatch.stop();
      setState(() {
        _isCompleted = true;
      });
      _saveCompletedPuzzle(_currentImageIndex);
      _showCompletionDialog();
    }
  }

  void _showImageModal() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _cachedImages.containsKey(_getImagePath(_currentImageIndex))
                      ? _cachedImages[_getImagePath(_currentImageIndex)]!
                      : Image.asset(
                    _getImagePath(_currentImageIndex),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
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
                    Text(
                      _getLocalizedTitle(_currentImageIndex),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLocalizedDescription(_currentImageIndex),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    final l10n = AppLocalizations.of(context);
    final timeInSeconds = _stopwatch.elapsed.inSeconds;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              l10n?.puzzleCompleted ?? '¡Puzzle Completado!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Mostrar imagen completa
            GestureDetector(
              onTap: _showImageModal,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _cachedImages.containsKey(_getImagePath(_currentImageIndex))
                      ? _cachedImages[_getImagePath(_currentImageIndex)]!
                      : Image.asset(
                    _getImagePath(_currentImageIndex),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getLocalizedTitle(_currentImageIndex),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n?.moves ?? 'Movimientos'}: $_moves',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n?.time ?? 'Tiempo'}: ${_formatTime(timeInSeconds)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              _getPerformanceMessage(l10n),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goToPuzzleSelector();
            },
            child: Text(l10n?.viewPuzzles ?? 'Ver Puzzles'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/minigames');
            },
            child: Text(l10n?.exit ?? 'Salir'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.resetPuzzle ?? '¿Reiniciar puzzle?'),
        content: Text(
            l10n?.resetPuzzleConfirmation ?? 'Este puzzle ya está completado. ¿Estás seguro de que quieres volver a hacerlo?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetPuzzle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.restart ?? 'Reiniciar'),
          ),
        ],
      ),
    );
  }

  void _resetPuzzle() {
    setState(() {
      _completedPuzzles.remove(_currentImageIndex);
    });
    _saveCompletedPuzzles();
    _initializePuzzle();
  }

  Future<void> _saveCompletedPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = _completedPuzzles.map((e) => e.toString()).toList();
    await prefs.setStringList('completed_puzzles', completedList);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getPerformanceMessage(AppLocalizations? l10n) {
    final optimalMoves = (_gridSize * _gridSize) * 2; // Estimación de movimientos óptimos

    if (_moves <= optimalMoves) {
      return l10n?.excellentStrategy ?? '¡Increíble! Resolviste el puzzle de manera muy eficiente.';
    } else if (_moves <= optimalMoves * 1.5) {
      return l10n?.goodStrategy ?? '¡Excelente trabajo! Tienes buena estrategia.';
    } else {
      return l10n?.keepPracticing ?? '¡Bien hecho! Sigue practicando para mejorar tu técnica.';
    }
  }

  String _getLocalizedTitle(int index) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n?.locale.languageCode ?? 'es';
    return _puzzleImages[index][languageCode]?['title'] ?? _puzzleImages[index]['es']!['title']!;
  }

  String _getLocalizedDescription(int index) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n?.locale.languageCode ?? 'es';
    return _puzzleImages[index][languageCode]?['description'] ?? _puzzleImages[index]['es']!['description']!;
  }

  String _getImagePath(int index) {
    return _puzzleImages[index]['path'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_showPuzzleSelector) {
          context.go('/minigames'); // Volver a la página de minijuegos
        } else {
          _goToPuzzleSelector(); // Volver a la selección de puzzles
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_showPuzzleSelector
              ? (l10n?.selectPuzzle ?? 'Seleccionar Puzzle')
              : (l10n?.puzzleSlider ?? 'Rompecabezas Deslizante')),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_showPuzzleSelector) {
                context.go('/minigames'); // Volver a la página de minijuegos
              } else {
                _goToPuzzleSelector(); // Volver a la selección de puzzles
              }
            },
          ),
          actions: _showPuzzleSelector ? [] : [
            if (_isCompleted)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _showResetConfirmation,
                tooltip: l10n?.restart ?? 'Reiniciar puzzle',
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _initializePuzzle,
                tooltip: l10n?.shuffleAgain ?? 'Mezclar de nuevo',
              ),
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: _goToPuzzleSelector,
              tooltip: l10n?.viewAllPuzzles ?? 'Ver todos los puzzles',
            ),
          ],
        ),
        body: _showPuzzleSelector ? _buildPuzzleSelector() : _buildPuzzleGame(),
      ),
    );
  }

  Widget _buildPuzzleSelector() {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          final maxWidth = isLargeScreen ? 900.0 : double.infinity;

          // Más columnas para hacer las cards más pequeñas
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 5; // Aumentado de 4 a 5
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 4; // Aumentado de 3 a 4
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3; // Aumentado de 2 a 3
          } else {
            crossAxisCount = 2;
          }

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                    child: Column(
                      children: [
                        Text(
                          l10n?.availablePuzzles ?? 'Rompecabezas Disponibles',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 24 : 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 8 : 6),
                        Text(
                          '${l10n?.progress ?? 'Progreso'}: ${_completedPuzzles.length}/${_puzzleImages.length} ${l10n?.completed ?? 'completados'}',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 16 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 16 : 12),
                        LinearProgressIndicator(
                          value: _completedPuzzles.length / _puzzleImages.length,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: isLargeScreen ? 16 : 12,
                        mainAxisSpacing: isLargeScreen ? 16 : 12,
                        childAspectRatio: 0.75, // Reducido para hacer las cards más compactas
                      ),
                      itemCount: _puzzleImages.length,
                      itemBuilder: (context, index) {
                        final isCompleted = _completedPuzzles.contains(index);
                        return GestureDetector(
                          onTap: () => _selectPuzzle(index),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  // Imagen de fondo
                                  Positioned.fill(
                                    child: _cachedImages.containsKey(_getImagePath(index))
                                        ? _cachedImages[_getImagePath(index)]!
                                        : Image.asset(
                                      _getImagePath(index),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error, size: 40),
                                        );
                                      },
                                    ),
                                  ),
                                  // Overlay con información
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Estado completado
                                  if (isCompleted)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: isLargeScreen ? 16 : 14,
                                        ),
                                      ),
                                    ),
                                  // Información del puzzle
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(isLargeScreen ? 10 : 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _getLocalizedTitle(index),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isLargeScreen ? 12 : 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: isLargeScreen ? 4 : 2),
                                          Text(
                                            _getLocalizedDescription(index),
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: isLargeScreen ? 10 : 9,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: isLargeScreen ? 6 : 4),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: isLargeScreen ? 8 : 6,
                                                vertical: isLargeScreen ? 4 : 3
                                            ),
                                            decoration: BoxDecoration(
                                              color: isCompleted ? Colors.green : Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              isCompleted
                                                  ? (l10n?.completed ?? 'Completado')
                                                  : (l10n?.playNow ?? 'Jugar'),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isLargeScreen ? 10 : 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPuzzleGame() {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          final maxWidth = isLargeScreen ? 700.0 : double.infinity;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  // Game info - más compacto
                  Container(
                    padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _getLocalizedTitle(_currentImageIndex),
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: isLargeScreen ? 8 : 6),
                            if (_completedPuzzles.contains(_currentImageIndex))
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: isLargeScreen ? 20 : 18,
                              ),
                          ],
                        ),
                        SizedBox(height: isLargeScreen ? 4 : 2),
                        Text(
                          _getLocalizedDescription(_currentImageIndex),
                          style: TextStyle(
                            fontSize: isLargeScreen ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isLargeScreen ? 12 : 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatCard(
                              icon: Icons.timer,
                              label: l10n?.time ?? 'Tiempo',
                              value: StreamBuilder(
                                stream: Stream.periodic(const Duration(seconds: 1)),
                                builder: (context, snapshot) {
                                  return Text(_formatTime(_stopwatch.elapsed.inSeconds));
                                },
                              ),
                              isLargeScreen: isLargeScreen,
                            ),
                            _StatCard(
                              icon: Icons.touch_app,
                              label: l10n?.moves ?? 'Movimientos',
                              value: Text('$_moves'),
                              isLargeScreen: isLargeScreen,
                            ),
                            _StatCard(
                              icon: Icons.image,
                              label: l10n?.progress ?? 'Progreso',
                              value: Text('${_completedPuzzles.length}/${_puzzleImages.length}'),
                              isLargeScreen: isLargeScreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Preview de la imagen completa (más pequeño)
                  GestureDetector(
                    onTap: _showImageModal,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: isLargeScreen ? 16 : 12),
                      padding: EdgeInsets.all(isLargeScreen ? 8 : 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isLargeScreen ? 50 : 40,
                            height: isLargeScreen ? 50 : 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _cachedImages.containsKey(_getImagePath(_currentImageIndex))
                                  ? _cachedImages[_getImagePath(_currentImageIndex)]!
                                  : Image.asset(
                                _getImagePath(_currentImageIndex),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error, size: 20),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: isLargeScreen ? 10 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      l10n?.viewCompleteImage ?? 'Ver imagen completa',
                                      style: TextStyle(
                                        fontSize: isLargeScreen ? 12 : 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: isLargeScreen ? 6 : 4),
                                    Icon(
                                      Icons.zoom_in,
                                      size: isLargeScreen ? 14 : 12,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                                if (_isCompleted)
                                  Text(
                                    l10n?.puzzleCompleted ?? '¡Completado!',
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 10 : 9,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Puzzle grid o imagen completa - MÁS GRANDE
                  Expanded(
                    child: Center(
                      child: _isCompleted
                          ? _buildCompletedImage(isLargeScreen)
                          : _buildPuzzleGrid(isLargeScreen),
                    ),
                  ),

                  // Instructions - más compacto
                  Padding(
                    padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                    child: Text(
                      _isCompleted
                          ? (l10n?.puzzleCompletedInstructions ?? '¡Puzzle completado! Puedes ver otros puzzles o reiniciar este.')
                          : (l10n?.puzzleInstructions ?? 'Toca las piezas adyacentes al espacio vacío para moverlas.\nOrdena las piezas para completar la imagen.'),
                      style: TextStyle(
                        fontSize: isLargeScreen ? 12 : 11,
                        color: _isCompleted ? Colors.green : null,
                        fontWeight: _isCompleted ? FontWeight.bold : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletedImage(bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.all(isLargeScreen ? 16 : 12),
      constraints: BoxConstraints(
        maxWidth: isLargeScreen ? 500 : 350, // Aumentado significativamente
        maxHeight: isLargeScreen ? 500 : 350,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: _cachedImages.containsKey(_getImagePath(_currentImageIndex))
              ? _cachedImages[_getImagePath(_currentImageIndex)]!
              : Image.asset(
            _getImagePath(_currentImageIndex),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 50),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzleGrid(bool isLargeScreen) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        margin: EdgeInsets.all(isLargeScreen ? 16 : 12),
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? 500 : 350, // Aumentado significativamente
          maxHeight: isLargeScreen ? 500 : 350,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalSize = constraints.maxWidth;
              final spacing = isLargeScreen ? 3.0 : 2.0;
              final tileSize = (totalSize - (spacing * (_gridSize - 1))) / _gridSize;

              return GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: _tiles.length,
                itemBuilder: (context, index) {
                  return _buildPuzzleTile(_tiles[index], index, tileSize);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzleTile(int number, int currentIndex, double tileSize) {
    if (number == -1) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey[400]!, width: 1),
        ),
        child: Center(
          child: Icon(
            Icons.crop_free,
            color: Colors.grey[500],
            size: 30,
          ),
        ),
      );
    }

    final correctRow = number ~/ _gridSize;
    final correctCol = number % _gridSize;

    return GestureDetector(
      onTap: () => _moveTile(currentIndex, true),
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: tileSize * _gridSize,
            maxHeight: tileSize * _gridSize,
            child: SizedBox(
              width: tileSize * _gridSize,
              height: tileSize * _gridSize,
              child: Transform.translate(
                offset: Offset(
                  -correctCol * tileSize,
                  -correctRow * tileSize,
                ),
                child: _cachedImages.containsKey(_getImagePath(_currentImageIndex))
                    ? _cachedImages[_getImagePath(_currentImageIndex)]!
                    : Image.asset(
                  _getImagePath(_currentImageIndex),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _getTileColor(number),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${number + 1}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTileColor(int number) {
    final colors = [
      Colors.red[400]!,
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.teal[400]!,
      Colors.pink[400]!,
      Colors.indigo[400]!,
    ];
    return colors[number % colors.length];
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;
  final bool isLargeScreen;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 10 : 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: isLargeScreen ? 18 : 16,
          ),
          SizedBox(height: isLargeScreen ? 4 : 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 10 : 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isLargeScreen ? 2 : 1),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: isLargeScreen ? 12 : 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            child: value,
          ),
        ],
      ),
    );
  }
}
