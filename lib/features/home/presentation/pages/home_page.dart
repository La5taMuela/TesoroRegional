import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/home/presentation/widgets/module_grid.dart';
import 'package:tesoro_regional/features/home/presentation/widgets/progress_summary.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return false;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitApp),
        content: Text(l10n.exitAppConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.exit),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(l10n.appName),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n.settings,
              onPressed: () => context.go('/settings'),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            color: Colors.grey[50],
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Container(
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
                          const Icon(Icons.extension, size: 80, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            l10n.appName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.welcomeSubtitle,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.go('/puzzle');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              l10n.startButton,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress summary
                    const ProgressSummary(
                      completionPercentage: 15.5,
                      collectedPieces: 3,
                      totalPieces: 25,
                    ),

                    const SizedBox(height: 24),

                    // Modules section
                    Text(
                      l10n.exploreSection,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Módulos en un grid responsivo
                    _buildResponsiveModuleGrid(context, l10n),

                    // Espacio extra para scroll
                    const SizedBox(height: 32),

                    // Minigames section
                    Text(
                      l10n.minigamesSection,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Minigames grid
                    _buildMinigamesGrid(context, l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveModuleGrid(BuildContext context, AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    final modules = [
      ModuleItem(
        title: l10n.puzzle,
        icon: Icons.extension,
        color: const Color(0xFF8B4513),
        onTap: () => context.go('/puzzle'),
      ),
      ModuleItem(
        title: l10n.map,
        icon: Icons.map,
        color: const Color(0xFF228B22),
        onTap: () => context.go('/map'),
      ),
      ModuleItem(
        title: l10n.missions,
        icon: Icons.flag,
        color: const Color(0xFFFFD700),
        onTap: () => context.go('/missions'),
      ),
      ModuleItem(
        title: l10n.stories,
        icon: Icons.book,
        color: const Color(0xFF8B4513),
        onTap: () => context.go('/stories'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: module.onTap,
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
                    module.color.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: module.color.withAlpha(30),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: module.color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      module.icon,
                      size: 32,
                      color: module.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    module.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinigamesGrid(BuildContext context, AppLocalizations l10n) {
    final minigames = [
      ModuleItem(
        title: l10n.triviaGame,
        icon: Icons.quiz,
        color: Colors.blue,
        onTap: () => context.go('/trivia'),
      ),
      ModuleItem(
        title: l10n.memoryGame,
        icon: Icons.memory,
        color: Colors.green,
        onTap: () => context.go('/memory-game'),
      ),
      ModuleItem(
        title: l10n.puzzleSlider,
        icon: Icons.extension,
        color: Colors.orange,
        onTap: () => context.go('/puzzle-slider'),
      ),
      ModuleItem(
        title: l10n.viewAll,
        icon: Icons.games,
        color: const Color(0xFF8B4513),
        onTap: () => context.go('/minigames'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: minigames.length,
      itemBuilder: (context, index) {
        final minigame = minigames[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: minigame.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    minigame.color.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: minigame.color.withAlpha(30),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: minigame.color.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      minigame.icon,
                      size: 24,
                      color: minigame.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          minigame.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.playNow,
                          style: TextStyle(
                            fontSize: 12,
                            color: minigame.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
