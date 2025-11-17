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
            .map((category) => _buildCategoryItem(context, category))
            .toList(),
      ),
    );
  }

  Widget _buildBackgroundImageView(String? imageUrl, ColorScheme colorScheme) {
    // Se imageUrl for null ou vazio, mostra placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.white10,
            size: 40,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          color: Colors.white70,
          strokeWidth: 2.0,
        ),
      ),
      errorWidget: (context, url, error) {
        return Container(
          color: Colors.grey.shade900,
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.white10,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = category.name == selectedCategoryName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () => onCategoryTap(category.name),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 3.0)
                : null,
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // MUDANÇA CRÍTICA: usar imageUrl ao invés de image
                _buildBackgroundImageView(category.imageUrl, colorScheme),

                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.black38],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.7),
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}