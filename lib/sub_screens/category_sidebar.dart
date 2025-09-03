import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategorySidebar extends StatelessWidget {
  final List<SupCatModel> categories;
  final String? selectedSuperCategory;
  final String? selectedSubCategory;
  final Function(String, String?) onCategorySelected;

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedSuperCategory,
    required this.selectedSubCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // If a super category is selected, only show that super category (and its subcategories).
    // Otherwise show all categories as before.
    final displayCategories = selectedSuperCategory != null
        ? categories.where((c) => c.name == selectedSuperCategory).toList()
        : categories;

    return Container(
      width: 100,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final superCategory = displayCategories[index];
          final isSelected = superCategory.name == selectedSuperCategory;

          return Column(
            children: [
              GestureDetector(
                onTap: () => onCategorySelected(superCategory.name, null),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.red, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: Icon(
                          _getCategoryIcon(superCategory.name),
                          color: isSelected ? Colors.red : Colors.grey[600],
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        superCategory.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? Colors.red : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected && superCategory.categories.isNotEmpty)
                ...superCategory.categories.map((subCat) {
                  final isSubSelected = subCat.name == selectedSubCategory;
                  return GestureDetector(
                    onTap: () =>
                        onCategorySelected(superCategory.name, subCat.name),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSubSelected
                            ? Colors.red[100]
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: isSubSelected
                            ? Border.all(color: Colors.red, width: 1)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // subcategory image above the name
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: _buildSubcategoryImage(subCat.image),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subCat.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSubSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSubSelected
                                  ? Colors.red
                                  : Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'vegetables':
        return Icons.eco;
      case 'dairy':
        return Icons.local_drink;
      case 'meat':
        return Icons.category;
      case 'bakery':
        return Icons.cake;
      case 'snacks':
        return Icons.fastfood;
      case 'beverages':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildSubcategoryImage(String imagePath) {
    // treat as network if it looks like a url, otherwise asset
    final isNetwork =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
      );
    }

    // asset fallback, with guard for empty path
    if (imagePath.isEmpty) {
      return const Icon(Icons.image, size: 20, color: Colors.grey);
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
    );
  }
}
