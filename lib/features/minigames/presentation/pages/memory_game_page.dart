import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:tesoro_regional/features/minigames/domain/entities/memory_card.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> with TickerProviderStateMixin {
  List<MemoryCard> _cards = [];
  List<int> _flippedIndices = [];
  int _matches = 0;
  int _moves = 0;
  bool _isProcessing = false;
  late Stopwatch _stopwatch;
  late AnimationController _flipController;

  // Mock data de lugares culturales de Ñuble
  final List<Map<String, String>> _culturalPlaces = [
    {'title': 'Plaza de Armas', 'category': 'Monumentos'},
    {'title': 'Catedral de Chillán', 'category': 'Arquitectura'},
    {'title': 'Mercado de Chillán', 'category': 'Gastronomía'},
    {'title': 'Nevados de Chillán', 'category': 'Naturaleza'},
    {'title': 'Museo de Ñuble', 'category': 'Historia'},
    {'title': 'Termas de Chillán', 'category': 'Turismo'},
    {'title': 'Cerámica Quinchamalí', 'category': 'Artesanía'},
    {'title': 'Longaniza San Carlos', 'category': 'Gastronomía'},
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _stopwatch = Stopwatch();
    _initializeGame();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void _initializeGame() {
    _stopwatch.start();

    // Crear pares de cartas
    final List<MemoryCard> cards = [];
    for (int i = 0; i < _culturalPlaces.length; i++) {
      final place = _culturalPlaces[i];
      // Crear dos cartas idénticas para cada lugar
      for (int j = 0; j < 2; j++) {
        cards.add(MemoryCard(
          id: '${place['title']}_$j',
          imageUrl: 'https://example.com/images/${place['title']?.toLowerCase().replaceAll(' ', '_')}.jpg',
          title: place['title']!,
          category: place['category']!,
        ));
      }
    }

    // Mezclar las cartas
    cards.shuffle(Random());

    setState(() {
      _cards = cards;
      _matches = 0;
      _moves = 0;
      _flippedIndices.clear();
      _isProcessing = false;
    });
  }

  void _onCardTapped(int index) {
    if (_isProcessing ||
        _cards[index].isFlipped ||
        _cards[index].isMatched ||
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

  void _checkForMatch() {
    setState(() {
      _isProcessing = true;
    });

    final firstIndex = _flippedIndices[0];
    final secondIndex = _flippedIndices[1];
    final firstCard = _cards[firstIndex];
    final secondCard = _cards[secondIndex];

    if (firstCard.title == secondCard.title) {
      // Es una pareja
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _cards[firstIndex] = _cards[firstIndex].copyWith(isMatched: true);
          _cards[secondIndex] = _cards[secondIndex].copyWith(isMatched: true);
          _matches++;
          _flippedIndices.clear();
          _isProcessing = false;
        });

        // Verificar si el juego ha terminado
        if (_matches == _culturalPlaces.length) {
          _stopwatch.stop();
          _showGameCompleted();
        }
      });
    } else {
      // No es una pareja
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
              context.go('/');
            },
            child: Text(l10n.exit),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getPerformanceMessage() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return 'Well done!';
    if (_moves <= _culturalPlaces.length + 2) {
      return l10n.excellentMemory;
    } else if (_moves <= _culturalPlaces.length * 1.5) {
      return l10n.greatWork;
    } else {
      return l10n.wellDone;
    }
  }

  void _restartGame() {
    _stopwatch.reset();
    _stopwatch.start();
    _initializeGame();
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
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.culturalMemory),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _restartGame,
              tooltip: l10n.restart,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Game stats
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.touch_app,
                        label: l10n.moves,
                        value: Text('$_moves'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.favorite,
                        label: l10n.pairs,
                        value: Text('$_matches/${_culturalPlaces.length}'),
                      ),
                    ),
                  ],
                ),
              ),

              // Game grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) {
                          return _MemoryCardWidget(
                            card: _cards[index],
                            onTap: () => _onCardTapped(index),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
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
          Icon(icon, color: Theme.of(context).primaryColor, size: 16),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 12,
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

class _MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const _MemoryCardWidget({
    required this.card,
    required this.onTap,
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
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(204),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.help_outline,
          size: 24,
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
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getCategoryColor(widget.card.category),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(widget.card.category),
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                widget.card.title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                widget.card.category,
                style: TextStyle(
                  fontSize: 8,
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'monumentos':
        return Colors.brown;
      case 'arquitectura':
        return Colors.blue;
      case 'gastronomía':
        return Colors.orange;
      case 'naturaleza':
        return Colors.green;
      case 'historia':
        return Colors.purple;
      case 'turismo':
        return Colors.teal;
      case 'artesanía':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'monumentos':
        return Icons.account_balance;
      case 'arquitectura':
        return Icons.architecture;
      case 'gastronomía':
        return Icons.restaurant;
      case 'naturaleza':
        return Icons.nature;
      case 'historia':
        return Icons.history_edu;
      case 'turismo':
        return Icons.tour;
      case 'artesanía':
        return Icons.palette;
      default:
        return Icons.place;
    }
  }
}
