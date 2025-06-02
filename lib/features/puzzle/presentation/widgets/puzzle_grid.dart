import 'package:flutter/material.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';

class PuzzleGrid extends StatelessWidget {
  final List<CulturalPiece> pieces;
  final Function(CulturalPiece) onPieceTapped;

  const PuzzleGrid({Key? key, required this.pieces, required this.onPieceTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: pieces.length,
      itemBuilder: (context, index) {
        final piece = pieces[index];
        return GestureDetector(
          onTap: () => onPieceTapped(piece),
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: piece.imageUrl != null
                ? Image.network(
              piece.imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return const Icon(Icons.image_not_supported, size: 40);
              },
            )
                : const Center(child: Text('No Image')),
          ),
        );
      },
    );
  }
}
