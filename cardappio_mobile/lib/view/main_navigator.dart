import 'package:flutter/material.dart';

import '../data/api_service.dart';
import '../model/cart_item.dart';
import '../model/category.dart';
import '../model/menu.dart';
import '../model/order_create_dto.dart';
import '../model/product.dart';
import '../model/ticket.dart';
import 'common/permanent_sidebar.dart';
import 'common/ticket_selection_dialog.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/menu/menu_detail_screen.dart';
import 'screens/menu/product_detail_screen.dart';
import 'screens/payment/payment_screen.dart';
import 'screens/ticket/ticket_screen.dart';

class MainNavigator extends StatefulWidget {
  final int initialIndex;
  const MainNavigator({super.key, this.initialIndex = 0});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with _CartManager, _NavigationManager, _CategoryManager {

  late final ApiService _apiService;

  Menu? _activeMenu;
  List<Category> _categories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _selectedIndex = widget.initialIndex;
    _selectedCategoryName = '';
    _initializeScreens();
  }

  Future<void> _loadCategories(String menuId) async {
    setState(() => _isLoadingCategories = true);

    try {
      final fetchedCategories = await _apiService.fetchCategories(menuId);
      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
          if (_categories.isNotEmpty) {
            _selectedCategoryName = _categories.first.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar categorias: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  void _initializeScreens() {
    _screens = [
      _buildCurrentMenuScreen(),
      _buildCartScreen(),
      HomeScreen(
        onQuickOrder: _handleQuickOrder,
        apiService: _apiService,
      ),
      TicketScreen(apiService: _apiService),
      PaymentScreen(apiService: _apiService),
    ];
  }

  void _updateScreens() {
    _screens[0] = _buildCurrentMenuScreen();
    _screens[1] = _buildCartScreen();
  }

  void _handleQuickOrder(Menu menu) {
    setState(() {
      _activeMenu = menu;
      _selectedIndex = 0;
    });
    _loadCategories(menu.id);
  }

  void _navigateToProductDetail(Product product) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          apiService: _apiService,
        ),
      ),
    );

    if (result != null) {
      _addItemToCart(product, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateScreens();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Cardappio',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 4,
        actions: [
          _buildCartIcon(),
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
                _onMenuItemTapped(2);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Use "Clique para Iniciar o Pedido" na Home para carregar o Cardápio.',
                    ),
                  ),
                );
              } else {
                _onMenuItemTapped(index);
              }
            },
            isMenuSelected: _selectedIndex == 0,
            categories: _categories,
            selectedCategoryName: _selectedCategoryName,
            onCategoryTap: (categoryName) =>
                setState(() => _selectedCategoryName = categoryName),
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMenuScreen() {
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
            Text(
              'Selecione um cardápio na tela Home para começar.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    String selectedCategoryId = '';
    if (_categories.isNotEmpty && _selectedCategoryName.isNotEmpty) {
      final selectedCategory = _categories.firstWhere(
            (cat) => cat.name == _selectedCategoryName,
        orElse: () => Category(id: '', name: ''),
      );
      selectedCategoryId = selectedCategory.id;
    }

    return MenuDetailScreen(
      menu: _activeMenu!,
      selectedCategoryName: _selectedCategoryName,
      selectedCategoryId: selectedCategoryId,
      onProductTap: _navigateToProductDetail,
      apiService: _apiService,
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

  Widget _buildCartIcon() {
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
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
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

mixin _NavigationManager on State<MainNavigator> {
  late int _selectedIndex;
  late List<Widget> _screens;

  void _onMenuItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }
}

mixin _CartManager on State<MainNavigator> {
  List<CartItem> _cartItems = [];
  double get _cartTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.lineTotal);
  int get _cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  ApiService get _apiService => (this as _MainNavigatorState)._apiService;

  void _addItemToCart(Product product, Map<String, dynamic> details) {
    setState(() {
      _cartItems.add(CartItem(
        product: product,
        quantity: details['quantity'] as int,
        lineTotal: details['total_item'] as double,
        details: details,
      ));
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${details['quantity']}x ${product.name} adicionado ao carrinho!',
          ),
        ),
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

  Future<void> _handleOrderConfirmation() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seu carrinho está vazio!')),
      );
      return;
    }

    final selectedTicket = await showDialog<Ticket>(
      context: context,
      builder: (_) => TicketSelectionDialog(),
    );

    if (selectedTicket == null) return;

    final orderItems = _cartItems.map((cartItem) {
      final addonsMap = cartItem.details['addons'] as Map<String, int>? ?? {};
      final additionalDtos = addonsMap.entries.map((entry) {
        return OrderItemAdditionalDTO(
          additionalId: entry.key,
          quantity: entry.value,
        );
      }).toList();

      return OrderItemDTO(
        productId: cartItem.product.id,
        quantity: cartItem.quantity,
        variableId: cartItem.details['variable'] as String?,
        observations: cartItem.details['observations'] as String?,
        additionals: additionalDtos,
      );
    }).toList();

    final orderDto = OrderCreateDTO(
      ticket: IdDTO(id: selectedTicket.id),
      status: EnumDTO(code: "1"),
      items: orderItems,
    );

    try {
      await _apiService.createOrder(orderDto);
      setState(() => _cartItems = []);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pedido enviado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao enviar o pedido: ${e.toString()}'),
          ),
        );
      }
    }
  }
}

mixin _CategoryManager on State<MainNavigator> {
  late String _selectedCategoryName;
}