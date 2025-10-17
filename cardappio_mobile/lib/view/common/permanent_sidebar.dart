import 'package:flutter/material.dart';

class PermanentSidebar extends StatelessWidget {
  final int selectedIndex;
  final int cartItemCount;
  final Function(int index) onTap;

  const PermanentSidebar({
    super.key,
    required this.selectedIndex,
    required this.cartItemCount,
    required this.onTap,
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
            child: ListView(
              padding: const EdgeInsets.only(top: 8.0),
              children: <Widget>[
                _buildSidebarItem(context, 0, Icons.menu_book, 'Cardápio', selectedIndex, onTap),
                _buildSidebarItem(context, 1, Icons.shopping_cart, 'Carrinho ($cartItemCount)', selectedIndex, onTap),
                _buildSidebarItem(context, 2, Icons.home, 'Home', selectedIndex, onTap),
                _buildSidebarItem(context, 3, Icons.receipt_long, 'Comanda', selectedIndex, onTap),
                _buildSidebarItem(context, 4, Icons.payment, 'Pagamento', selectedIndex, onTap),
              ],
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

  const Color defaultItemColor = Colors.white;
  final Color selectedBackgroundColor = defaultItemColor.withOpacity(0.2);

  return ListTile(
    leading: Icon(
      icon,
      color: defaultItemColor,
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: defaultItemColor,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
    selected: isSelected,
    selectedTileColor: selectedBackgroundColor,
    onTap: () => onTap(index),
  );
}