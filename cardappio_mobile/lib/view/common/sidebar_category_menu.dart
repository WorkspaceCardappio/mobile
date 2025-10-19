import 'package:flutter/material.dart';
import 'package:cardappio_mobile/data/mock_data.dart';
import 'package:cardappio_mobile/model/product.dart';

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
    // ... (método _getCategoryIcon permanece o mesmo)
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

    // Ajuste: A duração de saída é 0.
    return AnimatedSize(
      duration: Duration(milliseconds: isExpanded ? 300 : 0),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isExpanded
          ? Column( // O widget que expande e recolhe
        children: [
          // Adicionamos um Builder para forçar uma reconstrução limpa
          // E envolvemos o conteúdo em um Opacity animado
          AnimatedOpacity(
            opacity: isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: mockCategories.map((category) {
                final isSelected = category.name == selectedCategoryName;

                return Padding(
                  padding: const EdgeInsets.only(left: 10.0), // Recuo para sub-menu
                  child: ListTile(
                    leading: Icon(
                      _getCategoryIcon(category.icon),
                      color: defaultItemColor.withOpacity(isSelected ? 1.0 : 0.7),
                      size: 20,
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
          ),
        ],
      )
          : const SizedBox.shrink(), // Garantir que o tamanho seja zero quando fechado
    );
  }
}