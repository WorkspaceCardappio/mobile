import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90, 
      color: const Color(0xFF2E2E33), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSideMenuItem(Icons.star, 'Destaques', isSelected: false, onPressed: () {}),
          _buildSideMenuItem(Icons.menu_book, 'Cardápio', isSelected: false, onPressed: () {}),
          _buildSideMenuItem(Icons.receipt, 'Comandas', isSelected: true, onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSideMenuItem(IconData icon, String title, {required bool isSelected, VoidCallback? onPressed}) {
    final Color itemColor = isSelected ? Colors.red[600]! : Colors.white;
    

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextButton(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: itemColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: itemColor, size: 28),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: itemColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
 
  }
}