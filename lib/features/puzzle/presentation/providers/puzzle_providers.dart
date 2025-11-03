import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../state/puzzle_notifier.dart';
import '../state/puzzle_state.dart';

final puzzleStateProvider = StateNotifierProvider<PuzzleNotifier, PuzzleState>((ref) {
  try {
    print('✅ PuzzleProvider: Creating notifier with unified storage');
    return PuzzleNotifier(); // No parameters needed
  } catch (e, stackTrace) {
    print('❌ PuzzleProvider: Failed to create notifier: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});
