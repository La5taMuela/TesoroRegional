class PieceCategory {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int totalPieces;
  final int collectedPieces;

  const PieceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.totalPieces,
    this.collectedPieces = 0,
  });

  double get completionPercentage =>
      totalPieces > 0 ? (collectedPieces / totalPieces) * 100 : 0;

  bool get isComplete => collectedPieces >= totalPieces;
}
