import 'package:flutter/material.dart';


import '../../../data/api_service.dart';
import '../../../model/menu.dart';

class HomeScreen extends StatelessWidget {
  final Function(Menu menu) onQuickOrder;

  const HomeScreen({super.key, required this.onQuickOrder});

  void _handleQuickOrder(BuildContext context) async {
    final overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black54,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
    Overlay.of(context).insert(overlay);

    try {
      final List<Menu> menus = await ApiService.fetchMenus();

      final Menu? activeMenu = menus.isNotEmpty
          ? menus.firstWhere((m) => m.active, orElse: () => menus.first)
          : null;

      if (activeMenu != null) {
        onQuickOrder(activeMenu);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum cardápio disponível para iniciar o pedido.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar Cardápio: ${e.toString().split(':').last.trim()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      overlay.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bem-vindo ao Cardappio',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () => _handleQuickOrder(context),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fastfood,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Clique para Iniciar o Pedido',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}