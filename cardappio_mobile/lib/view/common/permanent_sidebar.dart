import 'package:cardappio_mobile/view/common/sidebar_category_menu.dart';
import 'package:flutter/material.dart';

import '../../model/category.dart';

class PermanentSidebar extends StatelessWidget {
  final List<Category> categories;
  final int selectedIndex;
  final int cartItemCount;
  final Function(int index) onTap;

  final bool isMenuSelected;
  final String selectedCategoryName;
  final Function(String categoryName) onCategoryTap;


  const PermanentSidebar({
    super.key,
    required this.selectedIndex,
    required this.cartItemCount,
    required this.onTap,
    required this.isMenuSelected,
    required this.selectedCategoryName,
    required this.onCategoryTap,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    const double sidebarWidth = 220;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 6,
            offset: Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0),
            width: double.infinity,
            color: primaryColor,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),

          Expanded(
            child: Scrollbar(
              child: ListView(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                children: <Widget>[


                  Column(
                    key: ValueKey('menu_group_$selectedIndex'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSidebarItem(context, 0, Icons.menu_book, 'Cardápio', selectedIndex, onTap),


                      SidebarCategoryMenu(
                        isExpanded: isMenuSelected,
                        selectedCategoryName: selectedCategoryName,
                        onCategoryTap: onCategoryTap,
                        categories: categories, // <-- AQUI é a nova propriedade obrigatória
                      ),
                    ],
                  ),

                  _buildSidebarItem(context, 1, Icons.shopping_cart, 'Carrinho ($cartItemCount)', selectedIndex, onTap),
                  _buildSidebarItem(context, 2, Icons.home, 'Home', selectedIndex, onTap),
                  _buildSidebarItem(context, 3, Icons.receipt_long, 'Comanda', selectedIndex, onTap),
                  _buildSidebarItem(context, 4, Icons.payment, 'Pagamento', selectedIndex, onTap),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSidebarItem(
    BuildContext context,
    int index,
    IconData icon,
    String title,
    int selectedIndex,
    Function(int) onTap,
    ) {
  final bool isSelected = selectedIndex == index;


  final Color itemTextColor = isSelected ? Colors.black87 : Colors.white;
  final Color itemIconColor = isSelected ? Colors.black87 : Colors.white;
  final Color selectedBackgroundColor = isSelected ? Colors.white.withOpacity(0.9) : Colors.transparent;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    decoration: BoxDecoration(
      color: selectedBackgroundColor,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: itemIconColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: itemTextColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: () => onTap(index),
    ),
  );
}