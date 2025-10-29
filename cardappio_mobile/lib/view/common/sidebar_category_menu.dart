import 'package:flutter/material.dart';
import '../../model/category.dart';

class SidebarCategoryMenu extends StatelessWidget {
  final bool isExpanded;
  final String selectedCategoryName;
  final ValueChanged<String> onCategoryTap;
  final List<Category> categories;

  const SidebarCategoryMenu({
    super.key,
    required this.isExpanded,
    required this.selectedCategoryName,
    required this.onCategoryTap,
    required this.categories,
  });


  static const Map<String, IconData> _categoryIcons = {
    'destaques do chef': Icons.star,
    'pratos principais': Icons.dinner_dining,
    'lanches e burgers': Icons.lunch_dining,
    'hambúrgueres': Icons.lunch_dining,
    'porções e petiscos': Icons.tapas,
    'bebidas': Icons.local_bar,
    'sobremesas': Icons.cake,
  };

  IconData _getIconForCategory(String categoryName) {
    return _categoryIcons[categoryName.toLowerCase()] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {

    if (!isExpanded) {
      return const SizedBox.shrink();
    }


    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: _buildMenuContent(context),
    );
  }

  Widget _buildMenuContent(BuildContext context) {


    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final menuBackgroundColor = Color.alphaBlend(
      colorScheme.onSurface.withOpacity(0.05),
      colorScheme.surface,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: menuBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(

        children: categories
            .map((category) => _buildCategoryItem(context, category, menuBackgroundColor))
            .toList(),
      ),
    );
  }



  Widget _buildCategoryItem(BuildContext context, Category category, Color menuBackgroundColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = category.name == selectedCategoryName;

    final selectedItemColor = Color.alphaBlend(
      colorScheme.primary.withOpacity(0.12),
      menuBackgroundColor,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: isSelected ? selectedItemColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
        leading: Icon(
          _getIconForCategory(category.name),
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.7),
          size: 18,
        ),
        title: Text(
          category.name,
          style: TextStyle(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => onCategoryTap(category.name),

        splashColor: selectedItemColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}