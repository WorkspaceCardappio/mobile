import 'package:flutter/material.dart';
import 'package:cardappio_mobile/data/mock_data.dart';

class SidebarCategoryMenu extends StatelessWidget {
  final bool isExpanded;
  final String selectedCategoryName;
  final Function(String categoryName) onCategoryTap;

  const SidebarCategoryMenu({
    super.key,
    required this.isExpanded,
    required this.selectedCategoryName,
    required this.onCategoryTap,
  });

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'star': return Icons.star;
      case 'dinner_dining': return Icons.dinner_dining;
      case 'lunch_dining': return Icons.lunch_dining;
      case 'tapas': return Icons.tapas;
      case 'local_bar': return Icons.local_bar;
      case 'cake': return Icons.cake;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color defaultItemColor = Colors.white;
    final Color selectedBackgroundColor = defaultItemColor.withOpacity(0.2);

    return AnimatedCrossFade(
      // Animação para aparecer e desaparecer o sub-menu
      duration: const Duration(milliseconds: 300),
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(), // Oculto
      secondChild: Column(
        children: mockCategories.map((category) {
          final isSelected = category.name == selectedCategoryName;

          return Padding(
            padding: const EdgeInsets.only(left: 10.0), // Recuo para sub-menu
            child: ListTile(
              leading: Icon(
                _getCategoryIcon(category.icon),
                color: defaultItemColor.withOpacity(isSelected ? 1.0 : 0.7),
                size: 20, // Ícones menores para sub-menu
              ),
              title: Text(
                category.name,
                style: TextStyle(
                  color: defaultItemColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
              selected: isSelected,
              selectedTileColor: selectedBackgroundColor,
              onTap: () => onCategoryTap(category.name),
            ),
          );
        }).toList(),
      ),
    );
  }
}