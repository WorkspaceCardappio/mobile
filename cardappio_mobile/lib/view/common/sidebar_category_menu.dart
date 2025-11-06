import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  // --- MÉTODOS DE ÍCONE REMOVIDOS ---
  // Não precisamos mais do _categoryIcons e _getIconForCategory.

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
    // Se a lista está vazia, pode ser que ainda esteja carregando, mas não temos
    // um estado de loading aqui, então vamos verificar a lista.
    if (categories.isEmpty) {
      // O CircularProgressIndicator aqui deve ser removido ou movido para onde o
      // _loadCategories é chamado para evitar um flash.
      // Neste contexto, se categories é vazia, significa que o carregamento falhou ou
      // o menu não tem categorias, então um SizedBox.shrink() pode ser mais adequado.
      return const SizedBox.shrink();
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

        // Substituindo o Icon pelo CachedNetworkImage
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: SizedBox(
            width: 24, // Define o tamanho fixo para a imagem
            height: 24,
            child: CachedNetworkImage(
              imageUrl: category.image, // Usando o link do modelo Category
              fit: BoxFit.cover,

              // Widget de placeholder enquanto carrega
              placeholder: (context, url) => Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              // Widget de erro se a imagem não carregar
              errorWidget: (context, url, error) {
                // 1. Ações de Debug (Prints)
                print('❌ FALHA AO CARREGAR: ${category.name}');
                print('   URL solicitada: $url');
                print('   Detalhes do Erro: $error');

                // 2. Retorno do Widget (Obrigatório)
                return Icon(
                  Icons.image_not_supported,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  size: 18,
                );
              },
            ),
          ),
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