import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesoro_regional/features/minigames/domain/entities/memory_card.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import 'package:tesoro_regional/core/services/content/memory_cards_service.dart' as memory_service;
import 'dart:convert';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> with TickerProviderStateMixin {
  final memory_service.MemoryCardsService _memoryCardsService = memory_service.MemoryCardsService();
  bool _hasInitialized = false;

  // Game state
  List<MemoryCard> _cards = [];
  List<int> _flippedIndices = [];
  int _matches = 0;
  int _moves = 0;
  bool _isProcessing = false;
  bool _isLoading = true;
  late Stopwatch _stopwatch;

  // Animation controllers
  late AnimationController _flipController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Category selection
  memory_service.MemoryCategory? _selectedCategory;
  List<memory_service.MemoryCategory> _categories = [];
  String _currentLanguage = 'es';

  // Progress tracking
  Map<String, int> _categoryProgress = {};
  Map<String, List<MemoryCard>> _discoveredPairs = {};

  // UI state
  bool _showDiscoveryPanel = false;
  MemoryCard? _lastDiscoveredCard;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _stopwatch = Stopwatch();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = Localizations.localeOf(context);
      _currentLanguage = locale.languageCode;
      _loadProgress();
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  // Load saved progress from SharedPreferences
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load category progress
      final progressKeys = prefs.getKeys()
          .where((key) => key.startsWith('memory_game_progress_'))
          .toList();

      Map<String, int> progress = {};
      for (var key in progressKeys) {
        final categoryId = key.replaceFirst('memory_game_progress_', '');
        progress[categoryId] = prefs.getInt(key) ?? 0;
      }

      // Load discovered pairs
      final discoveredKeys = prefs.getKeys()
          .where((key) => key.startsWith('memory_game_discovered_'))
          .toList();

      Map<String, List<MemoryCard>> discovered = {};
      for (var key in discoveredKeys) {
        final categoryId = key.replaceFirst('memory_game_discovered_', '');
        final jsonString = prefs.getString(key);

        if (jsonString != null) {
          try {
            final List<dynamic> cardsList = json.decode(jsonString);
            discovered[categoryId] = cardsList
                .map((cardJson) => MemoryCard.fromJson(cardJson))
                .toList();
          } catch (e) {
            print('Error parsing discovered pairs: $e');
          }
        }
      }

      setState(() {
        _categoryProgress = progress;
        _discoveredPairs = discovered;
      });

      print('Loaded progress for ${progress.length} categories');
      print('Loaded discovered pairs for ${discovered.length} categories');
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  // Save category progress
  Future<void> _saveCategoryProgress(String categoryId, int matchedPairs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('memory_game_progress_$categoryId', matchedPairs);

      setState(() {
        _categoryProgress[categoryId] = matchedPairs;
      });
    } catch (e) {
      print('Error saving category progress: $e');
    }
  }

  // Save discovered pairs
  Future<void> _saveDiscoveredPairs(String categoryId, List<MemoryCard> pairs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Eliminar duplicados antes de guardar
      final uniquePairs = pairs.fold<Map<String, MemoryCard>>({}, (map, card) {
        if (!map.containsKey(card.title)) {
          map[card.title] = card;
        }
        return map;
      }).values.toList();

      final jsonList = uniquePairs.map((card) => card.toJson()).toList();
      await prefs.setString('memory_game_discovered_$categoryId', json.encode(jsonList));

      setState(() {
        _discoveredPairs[categoryId] = uniquePairs;
      });
    } catch (e) {
      print('Error saving discovered pairs: $e');
    }
  }

  // Get progress for a category
  int getCategoryProgress(String categoryId) {
    return _categoryProgress[categoryId] ?? 0;
  }

  // Get discovered pairs for a category
  List<MemoryCard> getDiscoveredPairs(String categoryId) {
    final pairs = _discoveredPairs[categoryId] ?? [];
    // Eliminar posibles duplicados
    return pairs.fold<Map<String, MemoryCard>>({}, (map, card) {
      if (!map.containsKey(card.title)) {
        map[card.title] = card;
      }
      return map;
    }).values.toList();
  }
  // Check if a category is completed
  bool isCategoryCompleted(String categoryId, int totalPairs) {
    final progress = getCategoryProgress(categoryId);
    return progress >= totalPairs;
  }

  // Load categories from service
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _memoryCardsService.getCategories(_currentLanguage);

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _categories = _createFallbackCategories();
        _isLoading = false;
      });
    }
  }

  // Create fallback categories if loading fails
  List<memory_service.MemoryCategory> _createFallbackCategories() {
    return [
      memory_service.MemoryCategory(
        id: 'history',
        name: _currentLanguage == 'es' ? 'Historia' : 'History',
        description: 'Descubre la historia de Ñuble',
        icon: 'history_edu',
        color: 'purple',
        cards: [],
      ),
      memory_service.MemoryCategory(
        id: 'gastronomy',
        name: _currentLanguage == 'es' ? 'Gastronomía' : 'Gastronomy',
        description: 'Conoce los platos típicos',
        icon: 'restaurant',
        color: 'orange',
        cards: [],
      ),
      memory_service.MemoryCategory(
        id: 'nature',
        name: _currentLanguage == 'es' ? 'Naturaleza' : 'Nature',
        description: 'Explora los paisajes naturales',
        icon: 'nature',
        color: 'green',
        cards: [],
      ),
    ];
  }

  // Select a category and start game
  Future<void> _selectCategory(memory_service.MemoryCategory category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
      _showDiscoveryPanel = false;
    });

    try {
      final cards = await _memoryCardsService.getCardsForCategory(category.id, _currentLanguage);
      _initializeGameWithCards(cards, category);
    } catch (e) {
      print('Error loading cards for category: $e');
      final fallbackCards = _createFallbackCards(category);
      _initializeGameWithCards(fallbackCards, category);
    }
  }

  // Create fallback cards if loading fails
  List<MemoryCard> _createFallbackCards(memory_service.MemoryCategory category) {
    final places = [
      'Catedral de Chillán',
      'Mercado de Chillán',
      'Plaza de Armas',
      'Museo Claudio Arrau',
      'Casa de Violeta Parra',
      'Termas de Chillán',
    ];

    final cards = <MemoryCard>[];

    for (int i = 0; i < min(places.length, 6); i++) {
      cards.add(MemoryCard(
        id: 'card_$i',
        title: places[i],
        category: category.name,
        imageUrl: '',
      ));
    }

    return cards;
  }

  // Initialize game with cards
// Modifica el método _initializeGameWithCards para asegurar que las cartas descubiertas se muestren correctamente
  void _initializeGameWithCards(List<MemoryCard> sourceCards, memory_service.MemoryCategory category) {
    _stopwatch.reset();
    _stopwatch.start();

    // Cargar pares descubiertos para esta categoría
    final discoveredPairs = getDiscoveredPairs(category.id);
    final discoveredTitles = discoveredPairs.map((card) => card.title).toSet();

    // Crear pares de cartas
    final List<MemoryCard> gameCards = [];
    int preMatchedPairs = 0;

    // Primero añadir todas las cartas descubiertas
    for (final card in discoveredPairs) {
      for (int j = 0; j < 2; j++) {
        gameCards.add(MemoryCard(
          id: '${card.id}_$j',
          imageUrl: card.imageUrl,
          title: card.title,
          category: category.name,
          description: card.description,
          isMatched: true,
          isFlipped: true, // Asegurar que estén siempre visibles
        ));
      }
      preMatchedPairs++;
    }

    // Luego añadir las cartas no descubiertas
    for (final card in sourceCards) {
      if (!discoveredTitles.contains(card.title)) {
        for (int j = 0; j < 2; j++) {
          gameCards.add(MemoryCard(
            id: '${card.id}_$j',
            imageUrl: card.imageUrl,
            title: card.title,
            category: category.name,
            description: card.description,
            isMatched: false,
            isFlipped: false,
          ));
        }
      }
    }

    // Mezclar solo las cartas no descubiertas
    final unmatchedCards = gameCards.where((card) => !card.isMatched).toList();
    unmatchedCards.shuffle(Random());

    // Reconstruir la lista manteniendo las descubiertas en su lugar
    final List<MemoryCard> finalCards = [];
    int unmatchedIndex = 0;

    for (final card in gameCards) {
      if (card.isMatched) {
        finalCards.add(card);
      } else {
        finalCards.add(unmatchedCards[unmatchedIndex++]);
      }
    }

    setState(() {
      _cards = finalCards;
      _matches = preMatchedPairs;
      _moves = 0;
      _flippedIndices.clear();
      _isProcessing = false;
      _isLoading = false;
    });
  }

  // Handle card tap
  void _onCardTapped(int index) {
    if (_isProcessing ||
        _cards[index].isFlipped ||
        _cards[index].isMatched || // Añadir esta condición
        _flippedIndices.length >= 2) {
      return;
    }

    setState(() {
      _cards[index] = _cards[index].copyWith(isFlipped: true);
      _flippedIndices.add(index);
    });

    if (_flippedIndices.length == 2) {
      _moves++;
      _checkForMatch();
    }
  }

  // Check if flipped cards match
  void _checkForMatch() {
    setState(() {
      _isProcessing = true;
    });

    final firstIndex = _flippedIndices[0];
    final secondIndex = _flippedIndices[1];
    final firstCard = _cards[firstIndex];
    final secondCard = _cards[secondIndex];

    if (firstCard.title == secondCard.title) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _cards[firstIndex] = _cards[firstIndex].copyWith(
            isMatched: true,
            isFlipped: true, // Asegurar que permanezca visible
          );
          _cards[secondIndex] = _cards[secondIndex].copyWith(
            isMatched: true,
            isFlipped: true, // Asegurar que permanezca visible
          );
          _matches++;
          _flippedIndices.clear();
          _isProcessing = false;
        });

        // Añadir a pares desbloqueados
        if (_selectedCategory != null) {
          final categoryId = _selectedCategory!.id;
          final currentDiscovered = getDiscoveredPairs(categoryId);

          if (!currentDiscovered.any((card) => card.title == firstCard.title)) {
            final updatedDiscovered = [...currentDiscovered, firstCard];
            _saveDiscoveredPairs(categoryId, updatedDiscovered);
          }

          _saveCategoryProgress(categoryId, _matches);
        }

        if (_matches == (_cards.length ~/ 2)) {
          _stopwatch.stop();
          _showGameCompleted();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          _cards[firstIndex] = _cards[firstIndex].copyWith(isFlipped: false);
          _cards[secondIndex] = _cards[secondIndex].copyWith(isFlipped: false);
          _flippedIndices.clear();
          _isProcessing = false;
        });
      });
    }
  }

  // Show game completed dialog
  void _showGameCompleted() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
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
              l10n.congratulations,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.gameCompletedInMoves(_moves),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.gameTime(_formatTime(timeInSeconds)),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              _getPerformanceMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedCategory = null;
              });
            },
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_selectedCategory != null) {
                _selectCategory(_selectedCategory!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.playAgain),
          ),
        ],
      ),
    );
  }

  // Format time as MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get performance message based on moves
  String _getPerformanceMessage() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return 'Well done!';
    final expectedMoves = _cards.length ~/ 2;
    if (_moves <= expectedMoves + 2) {
      return l10n.excellentMemory;
    } else if (_moves <= expectedMoves * 1.5) {
      return l10n.greatWork;
    } else {
      return l10n.wellDone;
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_showDiscoveryPanel) {
          setState(() {
            _showDiscoveryPanel = false;
            _slideController.reverse();
          });
        } else if (_selectedCategory != null) {
          setState(() {
            _selectedCategory = null;
          });
        } else {
          context.go('/minigames');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selectedCategory?.name ?? l10n.culturalMemory),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_showDiscoveryPanel) {
                setState(() {
                  _showDiscoveryPanel = false;
                  _slideController.reverse();
                });
              } else if (_selectedCategory != null) {
                setState(() {
                  _selectedCategory = null;
                });
              } else {
                context.go('/minigames');
              }
            },
          ),
          actions: _selectedCategory != null ? [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _selectCategory(_selectedCategory!),
              tooltip: l10n.restart,
            ),
          ] : null,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _selectedCategory == null
            ? _buildCategorySelection(l10n)
            : _buildGameView(l10n),
      ),
    );
  }

  // Build category selection screen
// Modificación del método _buildCategorySelection
  Widget _buildCategorySelection(AppLocalizations l10n) {
    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay categorías disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;
        final maxWidth = isLargeScreen ? 1200.0 : double.infinity;

        // Configuración responsiva del grid
        int crossAxisCount;
        double childAspectRatio;
        double paddingValue;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 1.0;
          paddingValue = 24;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
          childAspectRatio = 1.0;
          paddingValue = 20;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.1;
          paddingValue = 16;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.4;
          paddingValue = 12;
        }

        return Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectCategory,
                style: TextStyle(
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isLargeScreen ? 16 : 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final totalPairs = category.cards.length;
                    final progress = getCategoryProgress(category.id);
                    final isCompleted = isCategoryCompleted(category.id, totalPairs);

                    return _CategoryCard(
                      category: category,
                      onTap: () => _selectCategory(category),
                      isLargeScreen: isLargeScreen,
                      progress: progress,
                      totalPairs: totalPairs,
                      isCompleted: isCompleted,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Modifica el método _buildGameView para cambiar la estructura del scroll
  Widget _buildGameView(AppLocalizations l10n) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          final isMediumScreen = constraints.maxWidth > 600;
          final isSmallScreen = constraints.maxWidth <= 600;

          // Configuración responsiva del grid
          int crossAxisCount;
          double childAspectRatio;
          double mainSpacing;
          double crossSpacing;

          if (isLargeScreen) {
            crossAxisCount = constraints.maxWidth > 1200 ? 6 : 5;
            childAspectRatio = 0.6;
            mainSpacing = 12;
            crossSpacing = 12;
          } else if (isMediumScreen) {
            crossAxisCount = 4;
            childAspectRatio = 0.75;
            mainSpacing = 10;
            crossSpacing = 10;
          } else {
            crossAxisCount = 4;
            childAspectRatio = 0.7;
            mainSpacing = 8;
            crossSpacing = 8;
          }

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  // Estadísticas y barra de progreso
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 24 : 16,
                      vertical: isLargeScreen ? 16 : 12,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.timer,
                                label: l10n.time,
                                value: StreamBuilder(
                                  stream: Stream.periodic(const Duration(seconds: 1)),
                                  builder: (context, snapshot) {
                                    return Text(_formatTime(_stopwatch.elapsed.inSeconds));
                                  },
                                ),
                                isLargeScreen: isLargeScreen,
                              ),
                            ),
                            SizedBox(width: isLargeScreen ? 12 : 8),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.touch_app,
                                label: l10n.moves,
                                value: Text('$_moves'),
                                isLargeScreen: isLargeScreen,
                              ),
                            ),
                            SizedBox(width: isLargeScreen ? 12 : 8),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.favorite,
                                label: l10n.pairs,
                                value: Text('$_matches/${_cards.length ~/ 2}'),
                                isLargeScreen: isLargeScreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isLargeScreen ? 12 : 8),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 24 : 16,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _cards.isEmpty ? 0 : _matches / (_cards.length / 2),
                              backgroundColor: Colors.grey[200],
                              color: _getCategoryColor(_selectedCategory?.color ?? 'blue'),
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tablero de juego con altura dinámica
                  Container(
                    padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                    constraints: BoxConstraints(
                      minHeight: isSmallScreen ? constraints.maxHeight * 0.5 : constraints.maxHeight * 0.6,
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: crossSpacing,
                        mainAxisSpacing: mainSpacing,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        return _MemoryCardWidget(
                          card: _cards[index],
                          onTap: () => _onCardTapped(index),
                          isLargeScreen: isLargeScreen,
                          categoryColor: _getCategoryColor(_selectedCategory?.color ?? 'blue'),
                        );
                      },
                    ),
                  ),

                  // Sección de pares desbloqueados
                  _buildDiscoveredPairsSection(isLargeScreen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Modifica el método _buildDiscoveredPairsSection para eliminar el scroll interno
  Widget _buildDiscoveredPairsSection(bool isLargeScreen) {
    if (_selectedCategory == null) return const SizedBox.shrink();

    final categoryId = _selectedCategory!.id;
    final discoveredPairs = getDiscoveredPairs(categoryId);
    final categoryColor = _getCategoryColor(_selectedCategory!.color);

    // Obtener cartas descubiertas del juego actual
    final currentlyDiscoveredCards = <MemoryCard>[];
    for (final card in _cards) {
      if (card.isMatched && !currentlyDiscoveredCards.any((c) => c.title == card.title)) {
        currentlyDiscoveredCards.add(card);
      }
    }

    if (currentlyDiscoveredCards.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search,
                size: isLargeScreen ? 48 : 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                _currentLanguage == 'es'
                    ? 'Encuentra pares para desbloquear lugares'
                    : 'Find pairs to unlock places',
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(isLargeScreen ? 16 : 12),
      padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_open,
                color: categoryColor,
                size: isLargeScreen ? 24 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                _currentLanguage == 'es' ? 'Pares Desbloqueados' : 'Unlocked Pairs',
                style: TextStyle(
                  fontSize: isLargeScreen ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          // Reemplazar ListView.separated por Column con Expanded
          Column(
            children: currentlyDiscoveredCards.map((pair) {
              return Padding(
                padding: EdgeInsets.only(bottom: isLargeScreen ? 8 : 6),
                child: Container(
                  padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: isLargeScreen ? 32 : 28,
                            height: isLargeScreen ? 32 : 28,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.place,
                              color: Colors.white,
                              size: isLargeScreen ? 16 : 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pair.title,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (pair.description != null && pair.description!.isNotEmpty) ...[
                        SizedBox(height: isLargeScreen ? 8 : 6),
                        Padding(
                          padding: EdgeInsets.only(left: isLargeScreen ? 44 : 40),
                          child: Text(
                            pair.description!,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 16 : 14,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Get color from category color name
  Color _getCategoryColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'red':
        return Colors.red;
      case 'amber':
        return Colors.amber;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  // Get icon from category icon name
  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'history_edu':
        return Icons.history_edu;
      case 'restaurant':
        return Icons.restaurant;
      case 'nature':
        return Icons.nature;
      case 'architecture':
        return Icons.architecture;
      case 'palette':
        return Icons.palette;
      case 'tour':
        return Icons.tour;
      case 'museum':
        return Icons.museum;
      case 'local_activity':
        return Icons.local_activity;
      case 'music_note':
        return Icons.music_note;
      default:
        return Icons.help;
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final memory_service.MemoryCategory category;
  final VoidCallback onTap;
  final bool isLargeScreen;
  final int progress;
  final int totalPairs;
  final bool isCompleted;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    this.isLargeScreen = false,
    required this.progress,
    required this.totalPairs,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category.color);
    final icon = _getCategoryIcon(category.icon);
    final progressPercent = totalPairs > 0 ? progress / totalPairs : 0.0;
    final titleStyle = TextStyle(
      fontSize: isLargeScreen ? 18 : 16,
      fontWeight: FontWeight.bold,
    );
    final descriptionStyle = TextStyle(
      fontSize: isLargeScreen ? 14 : 12,
      color: Colors.grey[600],
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and completion badge
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: isLargeScreen ? 24 : 20,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isLargeScreen ? 16 : 14,
                      ),
                    ),
                ],
              ),
              SizedBox(height: isLargeScreen ? 12 : 8),

              // Category name with marquee effect for long titles
              Text(
                category.name,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: isLargeScreen ? 4 : 2),

              // Category description
              Expanded(
                child: Text(
                  category.description,
                  style: descriptionStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // Progress indicator with fixed height
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso:',
                        style: descriptionStyle,
                      ),
                      Text(
                        '$progress/$totalPairs',
                        style: descriptionStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLargeScreen ? 6 : 4),
                  SizedBox(
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.grey[200],
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'red':
        return Colors.red;
      case 'amber':
        return Colors.amber;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'history_edu':
        return Icons.history_edu;
      case 'restaurant':
        return Icons.restaurant;
      case 'nature':
        return Icons.nature;
      case 'architecture':
        return Icons.architecture;
      case 'palette':
        return Icons.palette;
      case 'tour':
        return Icons.tour;
      case 'museum':
        return Icons.museum;
      case 'local_activity':
        return Icons.local_activity;
      case 'music_note':
        return Icons.music_note;
      default:
        return Icons.help;
    }
  }
}

// Stat card widget
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
      padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: isLargeScreen ? 20 : 16
          ),
          SizedBox(height: isLargeScreen ? 4 : 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 12 : 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? 4 : 2),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            child: value,
          ),
        ],
      ),
    );
  }
}

// Memory card widget with flip animation
class _MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final bool isLargeScreen;
  final Color categoryColor;

  const _MemoryCardWidget({
    required this.card,
    required this.onTap,
    this.isLargeScreen = false,
    required this.categoryColor,
  });

  @override
  State<_MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<_MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.card.isMatched ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = widget.card.isMatched ? false : _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(widget.card.isMatched ? 3.14159 : _flipAnimation.value * 3.14159),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.card.isMatched
                      ? Colors.green.withOpacity(0.3)
                      : null,
                ),
                child: isShowingFront ? _buildBack() : _buildFront(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.categoryColor,
            widget.categoryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.help_outline,
          size: widget.isLargeScreen ? 32 : 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        padding: EdgeInsets.all(widget.isLargeScreen ? 12 : 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widget.isLargeScreen ? 48 : 32,
              height: widget.isLargeScreen ? 48 : 32,
              decoration: BoxDecoration(
                color: widget.categoryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.place,
                color: Colors.white,
                size: widget.isLargeScreen ? 24 : 16,
              ),
            ),
            SizedBox(height: widget.isLargeScreen ? 12 : 8),
            Flexible(
              child: Text(
                widget.card.title,
                style: TextStyle(
                  fontSize: widget.isLargeScreen ? 16 : 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: widget.isLargeScreen ? 6 : 4),
            Flexible(
              child: Text(
                widget.card.category,
                style: TextStyle(
                  fontSize: widget.isLargeScreen ? 12 : 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Discovery panel widget
class _DiscoveryPanel extends StatelessWidget {
  final MemoryCard card;
  final bool isLargeScreen;
  final Color categoryColor;
  final VoidCallback onClose;

  const _DiscoveryPanel({
    required this.card,
    required this.isLargeScreen,
    required this.categoryColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 20 : 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: categoryColor,
                  size: isLargeScreen ? 24 : 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.pieceDiscovered ?? '¡Descubrimiento!',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  tooltip: l10n?.close ?? 'Cerrar',
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: isLargeScreen ? 60 : 50,
                  height: isLargeScreen ? 60 : 50,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.place,
                      color: categoryColor,
                      size: isLargeScreen ? 30 : 24,
                    ),
                  ),
                ),

                SizedBox(width: isLargeScreen ? 16 : 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.category,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : 12,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (card.description != null && card.description!.isNotEmpty) ...[
                        SizedBox(height: isLargeScreen ? 12 : 8),
                        Text(
                          card.description!,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 14 : 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action button
          Padding(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isLargeScreen ? 12 : 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n?.understood ?? 'Entendido',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
