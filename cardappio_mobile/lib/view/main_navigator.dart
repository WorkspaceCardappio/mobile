// NOVOS IMPORTS
import 'package:cardappio_mobile/model/category.dart';

import 'package:cardappio_mobile/view/screens/cart/cart_screen.dart';
import 'package:cardappio_mobile/view/screens/home/home_screen.dart';
import 'package:cardappio_mobile/view/screens/menu/menu_detail_screen.dart';
import 'package:cardappio_mobile/view/screens/menu/product_detail_screen.dart';
import 'package:cardappio_mobile/view/screens/payment/payment_screen.dart';
import 'package:cardappio_mobile/view/screens/ticket/ticket_screen.dart';
import 'package:flutter/material.dart';

// REMOVIDO: import '../data/mock_data.dart';
import '../data/api_service.dart';
import '../model/cart_item.dart';
import '../model/menu.dart';
import '../model/product.dart';
import 'common/permanent_sidebar.dart';

class MainNavigator extends StatefulWidget {
  final int initialIndex;
  const MainNavigator({super.key, this.initialIndex = 0});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> with _CartManager, _NavigationManager, _CategoryManager {
  Menu? _activeMenu;

  // NOVO: Estados para gerenciar as categorias vindas da API
  List<Category> _categories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _selectedCategoryName = ''; // ALTERADO: Inicia vazio, será preenchido após a API
    _initializeScreens();
  }

  // NOVO: Método para buscar as categorias da API
  Future<void> _loadCategories(String menuId) async {
    setState(() {
      _isLoadingCategories = true;
      _categories = []; // Limpa categorias antigas antes de buscar novas
    });

    try {
      final fetchedCategories = await ApiService.fetchCategories(menuId);
      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
          // Define a primeira categoria da lista como a selecionada por padrão
          if (_categories.isNotEmpty) {
            _selectedCategoryName = _categories.first.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
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
    // ALTERADO: Mostra um indicador de progresso enquanto as categorias carregam
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeMenu == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Selecione um cardápio na tela Home para começar.', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }
    return MenuDetailScreen(
      menu: _activeMenu!,
      selectedCategoryName: _selectedCategoryName,
      onProductTap: _navigateToProductDetail,
    );
  }

  Widget _buildCartScreen() {
    return CartScreen(
      cartItems: _cartItems,
      cartTotal: _cartTotal,
      onRemoveItem: _removeItemFromCart,
      onConfirmOrder: _handleOrderConfirmation,
    );
  }

  // ALTERADO: Agora dispara a busca de categorias
  void _handleQuickOrder(Menu menu) {
    setState(() {
      _activeMenu = menu;
      _selectedIndex = 0;
      _updateScreens();
    });
    // Dispara a busca pelas categorias assim que um menu é selecionado
    _loadCategories(menu.id);
  }

  void _handleOrderConfirmation() {
    setState(() {
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
            selectedIndex: _selectedIndex,
            cartItemCount: _cartItemCount,
            onTap: (index) {
              if (index == 0 && _activeMenu == null) {
                _onMenuItemTapped(2); // Vai para a Home
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Use "Clique para Iniciar o Pedido" na Home para carregar o Cardápio.')),
                );
              } else {
                _onMenuItemTapped(index);
              }
            },
            isMenuSelected: _selectedIndex == 0,

            // NOVO: Passando a lista de categorias para o Sidebar
            categories: _categories,

            selectedCategoryName: _selectedCategoryName,
            onCategoryTap: (categoryName) {
              setState(() {
                _selectedCategoryName = categoryName;
              });
            },
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    // ... (código do _buildCartIcon não precisa de alteração)
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
        if (_cartItemCount > 0)
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

mixin _NavigationManager on State<MainNavigator> {
  late int _selectedIndex;
  late List<Widget> _screens;

  void _onMenuItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

mixin _CartManager on State<MainNavigator> {
  // ... (código do _CartManager não precisa de alteração)
  List<CartItem> _cartItems = [];
  double get _cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  int get _cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

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

// ALTERADO: Mixin de Categoria agora é mais simples
mixin _CategoryManager on State<MainNavigator> {
  late String _selectedCategoryName;
// A função _getCategoryIcon foi movida para o widget 'SidebarCategoryMenu'
// pois é uma responsabilidade de UI e não de lógica de estado do navigator.
}