import 'package:cardappio_mobile/view/screens/cart/cart_screen.dart';
import 'package:cardappio_mobile/view/screens/home/home_screen.dart';
import 'package:cardappio_mobile/view/screens/menu/menu_detail_screen.dart';
import 'package:cardappio_mobile/view/screens/menu/product_detail_screen.dart';
import 'package:cardappio_mobile/view/screens/payment/payment_screen.dart';
import 'package:cardappio_mobile/view/screens/ticket/ticket_screen.dart';
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../model/cart_item.dart';
import '../model/menu.dart';
import '../model/product.dart';
import 'common/permanent_sidebar.dart';
import 'common/sidebar_category_menu.dart'; // NOVO IMPORT

class MainNavigator extends StatefulWidget {
  final int initialIndex;
  const MainNavigator({super.key, this.initialIndex = 0});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> with _CartManager, _NavigationManager, _CategoryManager {
  Menu? _activeMenu; // Definido aqui

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Inicializa a categoria com a primeira ao iniciar o navegador
    _selectedCategoryName = mockCategories.first.name;
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = [
      _buildCurrentMenuScreen(),
      _buildCartScreen(),
      HomeScreen(onQuickOrder: _handleQuickOrder),
      const TicketScreen(),
      const PaymentScreen(),
    ];
  }

  Widget _buildCurrentMenuScreen() {
    if (_activeMenu == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Aguardando Cardápio Ativo...', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }
    return MenuDetailScreen(
      menu: _activeMenu!,
      selectedCategoryName: _selectedCategoryName, // Propriedade do _CategoryManager
      onProductTap: _navigateToProductDetail,
    );
  }

  Widget _buildCartScreen() {
    return CartScreen(
      cartItems: _cartItems, // Propriedade do _CartManager
      cartTotal: _cartTotal, // Propriedade do _CartManager
      onRemoveItem: _removeItemFromCart, // Método do _CartManager
      onConfirmOrder: _handleOrderConfirmation,
    );
  }

  void _handleQuickOrder(Menu menu) {
    setState(() {
      _activeMenu = menu;
      // Define a primeira categoria ao carregar um novo menu
      _selectedCategoryName = mockCategories.first.name;
      _selectedIndex = 0;
      _updateScreens();
    });
  }

  void _handleOrderConfirmation() {
    setState(() {
      // Simulação de envio de pedido
      _cartItems = [];
      _updateScreens();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Pedido enviado com sucesso!')),
    );
  }

  void _navigateToProductDetail(Product product) async {
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );

    if (result != null) {
      _addItemToCart(product, result['quantity'] as int);
    }
  }

  // MÉTODO DEFINIDO AQUI
  void _updateScreens() {
    _screens[0] = _buildCurrentMenuScreen();
    _screens[1] = _buildCartScreen();
  }

  @override
  Widget build(BuildContext context) {
    _updateScreens();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cardappio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        elevation: 4,
        actions: [
          _buildCartIcon(context),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          PermanentSidebar(
            selectedIndex: _selectedIndex, // Propriedade do _NavigationManager
            cartItemCount: _cartItemCount, // Propriedade do _CartManager
            onTap: (index) {
              _onMenuItemTapped(index);
            },
            // Passa a lógica de categoria para que o Sidebar possa construir o submenu
            isMenuSelected: _selectedIndex == 0,
            selectedCategoryName: _selectedCategoryName, // Propriedade do _CategoryManager
            onCategoryTap: (categoryName) {
              setState(() {
                _selectedCategoryName = categoryName; // Atualiza o estado da categoria
              });
            },
          ),
          Expanded(
            child: _screens[_selectedIndex], // Propriedade do _NavigationManager
          ),
        ],
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, size: 28),
          onPressed: () {
            if (_selectedIndex != 1) {
              _onMenuItemTapped(1);
            }
          },
          tooltip: 'Carrinho de Pedidos',
        ),
        if (_cartItemCount > 0) // Propriedade do _CartManager
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                '$_cartItemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// MIXINS
// ----------------------------------------------------------------------------

// Mixin para gerenciar a Lógica de Navegação
mixin _NavigationManager on State<MainNavigator> {
  late int _selectedIndex; // DEFINIÇÃO AQUI
  late List<Widget> _screens; // DEFINIÇÃO AQUI

  void _onMenuItemTapped(int index) { // DEFINIÇÃO AQUI
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Mixin para gerenciar a Lógica do Carrinho
mixin _CartManager on State<MainNavigator> {
  List<CartItem> _cartItems = [];
  double get _cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  int get _cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity); // DEFINIÇÃO AQUI

  void _addItemToCart(Product product, int quantity) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex].quantity += quantity;
      } else {
        _cartItems.add(CartItem(product: product, quantity: quantity));
      }
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${quantity}x ${product.name} adicionado ao carrinho!')),
      );
    }
  }

  void _removeItemFromCart(String productId) {
    setState(() {
      _cartItems.removeWhere((item) => item.product.id == productId);
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removido do carrinho.')),
      );
    }
  }
}

// Mixin para gerenciar a Lógica de Categorias
mixin _CategoryManager on State<MainNavigator> {
  late String _selectedCategoryName; // DEFINIÇÃO AQUI

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
}