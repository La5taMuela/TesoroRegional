import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

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
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(204),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
        onTap: () => _navigateToTrivia(context),
      ),
      GameItem(
        title: l10n.memoryGame,
        description: l10n.memoryDescription,
        icon: Icons.memory,
        color: Colors.green,
        onTap: () => _navigateToMemoryGame(context),
      ),
      GameItem(
        title: l10n.puzzleSlider,
        description: l10n.puzzleDescription,
        icon: Icons.extension,
        color: Colors.orange,
        onTap: () => _navigateToPuzzleSlider(context),
      ),
      GameItem(
        title: l10n.comingSoon,
        description: l10n.moreGamesInDevelopment,
        icon: Icons.construction,
        color: Colors.grey,
        onTap: () => _showComingSoon(context, l10n),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _GameCard(game: game);
      },
    );
  }

  void _navigateToTrivia(BuildContext context) {
    context.go('/trivia');
  }

  void _navigateToMemoryGame(BuildContext context) {
    context.go('/memory-game');
  }

  void _navigateToPuzzleSlider(BuildContext context) {
    context.go('/puzzle-slider');
  }

  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.comingSoon),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              l10n.workingOnMoreGames,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.understood),
          ),
        ],
      ),
    );
  }
}

class GameItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const GameItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _GameCard extends StatelessWidget {
  final GameItem game;

  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: game.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                game.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: game.color.withAlpha(30),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: game.color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  game.icon,
                  size: 32,
                  color: game.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                game.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  game.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
