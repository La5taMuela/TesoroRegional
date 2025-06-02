import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/features/puzzle/presentation/state/puzzle_notifier.dart';
import 'package:tesoro_regional/features/puzzle/presentation/state/puzzle_state.dart';

final puzzleStateProvider = StateNotifierProvider<PuzzleNotifier, PuzzleState>((ref) {
  return PuzzleNotifier();
});
