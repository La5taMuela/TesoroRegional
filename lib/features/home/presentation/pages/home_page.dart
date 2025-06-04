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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determinar si es una pantalla grande
                final isLargeScreen = constraints.maxWidth > 800;
                final maxContentWidth = isLargeScreen ? 1200.0 : double.infinity;

                return Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
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
                                  Icon(
                                      Icons.extension,
                                      size: isLargeScreen ? 100 : 80,
                                      color: Colors.white
                                  ),
                                  SizedBox(height: isLargeScreen ? 20 : 16),
                                  Text(
                                    l10n.appName,
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 32 : 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: isLargeScreen ? 12 : 8),
                                  Text(
                                    l10n.welcomeSubtitle,
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 18 : 16,
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isLargeScreen ? 32 : 24),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.go('/puzzle');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Theme.of(context).primaryColor,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: isLargeScreen ? 40 : 32,
                                          vertical: isLargeScreen ? 20 : 16
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                      l10n.startButton,
                                      style: TextStyle(
                                        fontSize: isLargeScreen ? 20 : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isLargeScreen ? 32 : 24),

                            // Progress summary
                            const ProgressSummary(
                              completionPercentage: 15.5,
                              collectedPieces: 3,
                              totalPieces: 25,
                            ),

                            SizedBox(height: isLargeScreen ? 32 : 24),

                            // Modules section
                            Text(
                              l10n.exploreSection,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                fontSize: isLargeScreen ? 24 : 20,
                              ),
                            ),
                            SizedBox(height: isLargeScreen ? 20 : 16),

                            // Módulos en un grid responsivo
                            _buildResponsiveModuleGrid(context, l10n),

                            // Espacio extra para scroll
                            SizedBox(height: isLargeScreen ? 40 : 32),

                            // Minigames section
                            Text(
                              l10n.minigamesSection,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                fontSize: isLargeScreen ? 24 : 20,
                              ),
                            ),
                            SizedBox(height: isLargeScreen ? 20 : 16),

                            // Minigames grid
                            _buildMinigamesGrid(context, l10n),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveModuleGrid(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar el número de columnas basado en el ancho de pantalla
        int crossAxisCount;
        double maxWidth;

        if (constraints.maxWidth > 1200) {
          // Desktop grande
          crossAxisCount = 4;
          maxWidth = 1200;
        } else if (constraints.maxWidth > 800) {
          // Desktop/Tablet
          crossAxisCount = 3;
          maxWidth = 800;
        } else if (constraints.maxWidth > 600) {
          // Tablet pequeño
          crossAxisCount = 2;
          maxWidth = double.infinity;
        } else {
          // Móvil
          crossAxisCount = 2;
          maxWidth = double.infinity;
        }

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
                childAspectRatio: constraints.maxWidth > 600 ? 1.2 : 1.1,
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
                      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12),
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
                            padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12),
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
                              size: constraints.maxWidth > 600 ? 32 : 28,
                              color: module.color,
                            ),
                          ),
                          SizedBox(height: constraints.maxWidth > 600 ? 12 : 8),
                          Text(
                            module.title,
                            style: TextStyle(
                              fontSize: constraints.maxWidth > 600 ? 16 : 14,
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinigamesGrid(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double maxWidth;
        double childAspectRatio;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          maxWidth = 1200;
          childAspectRatio = 1.6;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
          maxWidth = 800;
          childAspectRatio = 1.5;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          maxWidth = double.infinity;
          childAspectRatio = 1.4;
        } else {
          crossAxisCount = 2;
          maxWidth = double.infinity;
          childAspectRatio = 1.3;
        }

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
                      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 12 : 8),
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
                            padding: EdgeInsets.all(constraints.maxWidth > 600 ? 12 : 8),
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
                              size: constraints.maxWidth > 600 ? 24 : 20,
                              color: minigame.color,
                            ),
                          ),
                          SizedBox(width: constraints.maxWidth > 600 ? 12 : 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  minigame.title,
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth > 600 ? 14 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.playNow,
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth > 600 ? 12 : 10,
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
            ),
          ),
        );
      },
    );
  }
}
