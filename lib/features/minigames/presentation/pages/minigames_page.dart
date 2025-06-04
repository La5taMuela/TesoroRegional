import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import 'package:tesoro_regional/features/minigames/presentation/widgets/minigame_card.dart';

class MinigamesPage extends StatelessWidget {
  const MinigamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Verificación de null safety
    if (l10n == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minijuegos'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(
          child: Text('Cargando traducciones...'),
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
          title: Text(l10n.minigames),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, l10n),
              const SizedBox(height: 24),
              _buildGameGrid(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513), // Café color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.games, size: 60, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            l10n.culturalMinigames,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.learnPlayingSubtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid(BuildContext context, AppLocalizations l10n) {
    final games = [
      GameItem(
        title: l10n.triviaGame,
        description: l10n.triviaDescription,
        icon: Icons.quiz,
        color: Colors.blue,
        onTap: () => context.go('/trivia'),
      ),
      GameItem(
        title: l10n.memoryGame,
        description: l10n.memoryDescription,
        icon: Icons.memory,
        color: Colors.green,
        onTap: () => context.go('/memory-game'),
      ),
      GameItem(
        title: l10n.puzzleSlider,
        description: l10n.puzzleDescription,
        icon: Icons.extension,
        color: Colors.orange,
        onTap: () => context.go('/puzzle-slider'),
      ),
      GameItem(
        title: l10n.comingSoon,
        description: l10n.workingOnMoreGames,
        icon: Icons.games,
        color: const Color(0xFF8B4513),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.comingSoon),
              content: Text(l10n.workingOnMoreGames),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.understood),
                ),
              ],
            ),
          );
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double maxWidth;
        double childAspectRatio;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          maxWidth = 1200;
          childAspectRatio = 1.0;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
          maxWidth = 800;
          childAspectRatio = 0.9;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          maxWidth = double.infinity;
          childAspectRatio = 0.8;
        } else {
          crossAxisCount = 2;
          maxWidth = double.infinity;
          childAspectRatio = 0.7;
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return MinigameCard(
                  game: game,
                  isLargeScreen: constraints.maxWidth > 600,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class GameItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  GameItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}