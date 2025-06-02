import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/features/home/presentation/pages/home_page.dart';
import 'package:tesoro_regional/features/puzzle/presentation/pages/puzzle_page.dart';
import 'package:tesoro_regional/features/map/presentation/pages/map_page.dart';
import 'package:tesoro_regional/features/stories/presentation/pages/stories_page.dart';
import 'package:tesoro_regional/features/missions/presentation/pages/missions_page.dart';
import 'package:tesoro_regional/features/settings/presentation/pages/settings_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/minigames_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/trivia_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/memory_game_page.dart';
import 'package:tesoro_regional/features/minigames/presentation/pages/puzzle_slider_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/puzzle',
        builder: (context, state) => const PuzzlePage(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: '/missions',
        builder: (context, state) => const MissionsPage(),
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const StoriesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/minigames',
        builder: (context, state) => const MinigamesPage(),
      ),
      GoRoute(
        path: '/trivia',
        builder: (context, state) => const TriviaPage(),
      ),
      GoRoute(
        path: '/memory-game',
        builder: (context, state) => const MemoryGamePage(),
      ),
      GoRoute(
        path: '/puzzle-slider',
        builder: (context, state) => const PuzzleSliderPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri.path}'),
      ),
    ),
  );
});
