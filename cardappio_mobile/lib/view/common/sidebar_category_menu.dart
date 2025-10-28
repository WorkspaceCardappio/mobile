import 'package:flutter/material.dart';
// Mantenha suas importações de mock_data e product aqui
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // NOVO: Cor de fundo para o menu inteiro.
    // Usamos Color.alphaBlend para misturar a cor do texto (onSurface) com 5% de opacidade
    // sobre a cor de fundo padrão (surface). Isso cria um tom sutilmente mais claro.
    final Color menuBackgroundColor = Color.alphaBlend(
      colorScheme.onSurface.withOpacity(0.05),
      colorScheme.surface,
    );

    // ALTERADO: A cor do item selecionado agora é uma mistura da cor primária
    // sobre o novo fundo do menu, para um contraste mais harmonioso.
    final Color selectedItemBackgroundColor = Color.alphaBlend(
      colorScheme.primary.withOpacity(0.12),
      menuBackgroundColor,
    );

    final Color unselectedItemColor = colorScheme.onSurface;

    return AnimatedSize(
      duration: Duration(milliseconds: isExpanded ? 300 : 0),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isExpanded
      // NOVO: Container principal que define o fundo de todo o menu.
          ? Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Espaçamento interno
        decoration: BoxDecoration(
          color: menuBackgroundColor, // Aplicando a nova cor de fundo
          borderRadius: BorderRadius.circular(12.0), // Bordas arredondadas para o menu
        ),
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: mockCategories.map((category) {
                  final isSelected = category.name == selectedCategoryName;

                  return Container(
                    // ALTERADO: Ajustado o margin para se adequar ao novo container pai
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                    decoration: BoxDecoration(
                      // ALTERADO: Usando a nova cor para o item selecionado
                      color: isSelected
                          ? selectedItemBackgroundColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      leading: Icon(
                        _getCategoryIcon(category.icon),
                        color: isSelected
                            ? colorScheme.primary
                            : unselectedItemColor.withOpacity(0.7),
                        size: 18,
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.primary
                              : unselectedItemColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}