import 'package:flutter/material.dart';

import '../../../data/api_service.dart';
import '../../../model/menu.dart';

class HomeScreen extends StatefulWidget {
  final Function(Menu menu) onQuickOrder;
  final ApiService apiService;

  const HomeScreen({
    super.key,
    required this.onQuickOrder,
    required this.apiService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  Future<void> _performQuickOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Menu> menus = await widget.apiService.fetchMenus();
      final Menu? activeMenu = menus.isNotEmpty
          ? menus.firstWhere((m) => m.active, orElse: () => menus.first)
          : null;

      if (activeMenu != null) {
        widget.onQuickOrder(activeMenu);
      } else {
        _showErrorSnackBar('Nenhum cardápio disponível para iniciar o pedido.');
      }
    } catch (e) {
      final errorMessage = e.toString().split(':').last.trim();
      _showErrorSnackBar('Erro ao buscar Cardápio: $errorMessage');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
            onTap: _isLoading ? null : _performQuickOrder,
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
              child: _buildButtonChild(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Clique para Iniciar o Pedido',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonChild() {
    if (_isLoading) {
      return const SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 6,
        ),
      );
    } else {
      return const Icon(
        Icons.fastfood,
        size: 100,
        color: Colors.white,
      );
    }
  }
}