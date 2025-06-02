import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';

import '../../domain/entities/piece_category.dart';

// Simplified state without Freezed for now
abstract class PuzzleState {
  const PuzzleState();
}

class PuzzleInitial extends PuzzleState {
  const PuzzleInitial();
}

class PuzzleLoading extends PuzzleState {
  const PuzzleLoading();
}

class PuzzleLoaded extends PuzzleState {
  final List<PieceCategory> categories;
  final List<CulturalPiece> collectedPieces;
  final double completionPercentage;
  final String? selectedCategoryId;

  const PuzzleLoaded({
    required this.categories,
    required this.collectedPieces,
    required this.completionPercentage,
    this.selectedCategoryId,
  });

  PuzzleLoaded copyWith({
    List<PieceCategory>? categories,
    List<CulturalPiece>? collectedPieces,
    double? completionPercentage,
    String? selectedCategoryId,
  }) {
    return PuzzleLoaded(
      categories: categories ?? this.categories,
      collectedPieces: collectedPieces ?? this.collectedPieces,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

class PuzzleError extends PuzzleState {
  final String message;

  const PuzzleError(this.message);
}
