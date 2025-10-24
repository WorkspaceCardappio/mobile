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

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.85)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.0),
                    border: isSelected
                        ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.0)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                    leading: Icon(
                      _getCategoryIcon(category.icon),
                      color: isSelected
                          ? Colors.black87
                          : defaultItemColor.withOpacity(0.8),
                      size: 18,
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black87
                            : defaultItemColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
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