import 'package:flutter/material.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class CategorySelector extends StatelessWidget {
  final List<PieceCategory> categories;
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: isSelected ? 8 : 2,
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isSelected
                    ? BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () => onCategorySelected(category.id),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon placeholder
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(category.name),
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Category name
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Progress
                      Text(
                        '${category.collectedPieces}/${category.totalPieces}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    switch (lowerName) {
      case 'tradiciones':
      case 'traditions':
        return Icons.celebration;
      case 'lugares':
      case 'places':
        return Icons.location_on;
      case 'gastronomía':
      case 'gastronomy':
        return Icons.restaurant;
      case 'artesanía':
      case 'crafts':
        return Icons.palette;
      case 'monumentos':
      case 'monuments':
        return Icons.account_balance;
      case 'historia':
      case 'history':
        return Icons.history_edu;
      default:
        return Icons.category;
    }
  }
}
