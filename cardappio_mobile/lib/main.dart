import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ----------------------------------------------------------------------------
// TELA BASE E NAVEGAÇÃO
// ----------------------------------------------------------------------------

void main() {
  runApp(const CardappioApp());
}

class CardappioApp extends StatelessWidget {
  const CardappioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardappio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDF6B4B),
          primary: const Color(0xFFDF6B4B),
          secondary: const Color(0xFF2C3E50),
          surface: const Color(0xFFF1F5F9),
          background: const Color(0xFFF1F5F9),
          onPrimary: Colors.white,
          onBackground: const Color(0xFF2C3E50),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFDF6B4B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const BaseScreen(initialIndex: 2),
    );
  }
}

// ----------------------------------------------------------------------------
// TELA BASE COM DRAWER E TROCA DE TELA (Gerencia o Carrinho)
// ----------------------------------------------------------------------------

class BaseScreen extends StatefulWidget {
  final int initialIndex;
  const BaseScreen({super.key, this.initialIndex = 0});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 2;
  Menu? _activeMenu;

  // NOVO: Gerenciamento de Estado do Carrinho
  List<CartItem> _cartItems = [];
  double get _cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  int get _cartItemCount => _cartItems.length;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _screens = [
      _buildCurrentMenuScreen(),
      CarrinhoScreen(
        cartItems: _cartItems,
        cartTotal: _cartTotal,
        onRemoveItem: _removeItemFromCart,
      ),
      HomeScreen(onQuickOrder: _handleQuickOrder),
      const ComandaScreen(),
    ];
  }

  // Função para adicionar item ao carrinho
  void _addItemToCart(Product product, int quantity) {
    setState(() {
      // Cria um novo item de carrinho
      final newItem = CartItem(
        product: product,
        quantity: quantity,
      );

      // Verifica se o item já existe para apenas atualizar a quantidade
      final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex != -1) {
        // Se existir, atualiza a quantidade
        _cartItems[existingItemIndex].quantity += quantity;
      } else {
        // Se for novo, adiciona
        _cartItems.add(newItem);
      }

      // Atualiza a tela do carrinho para refletir os novos dados
      _screens[1] = CarrinhoScreen(
        cartItems: _cartItems,
        cartTotal: _cartTotal,
        onRemoveItem: _removeItemFromCart,
      );
    });

    // CORREÇÃO AQUI: Usando 'quantity' corretamente.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${quantity}x ${product.name} adicionado ao carrinho!')),
    );
  }

  // Função para remover item do carrinho
  void _removeItemFromCart(String productId) {
    setState(() {
      _cartItems.removeWhere((item) => item.product.id == productId);
      // Atualiza a tela do carrinho
      _screens[1] = CarrinhoScreen(
        cartItems: _cartItems,
        cartTotal: _cartTotal,
        onRemoveItem: _removeItemFromCart,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removido do carrinho.')),
    );
  }

  Widget _buildCurrentMenuScreen() {
    if (_activeMenu == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando Cardápio...'),
          ],
        ),
      );
    }
    // Passa a função de adicionar ao carrinho para a tela de detalhes
    return MenuDetailScreen(
      menu: _activeMenu!,
      onProductTap: _showAddProductModal,
    );
  }

  // Função que a HomeScreen chama para iniciar o pedido
  void _handleQuickOrder(Menu menu) {
    setState(() {
      _activeMenu = menu;
      _selectedIndex = 0;
    });
  }

  // NOVO: Exibe a modal de Adicionar Produto
  void _showAddProductModal(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AddProductModal(
          product: product,
          onConfirm: (quantity) {
            _addItemToCart(product, quantity);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _onMenuItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 0) {
      _screens[0] = _buildCurrentMenuScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardappio - Pedido de Mesa', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 4,
        actions: [
          // ÍCONE DE CARRINHO NO APPBAR COM CONTADOR
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _onMenuItemTapped(1), // Vai para a tela de carrinho
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
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.restaurant_menu, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Cardappio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Cardápio'),
              selected: _selectedIndex == 0,
              onTap: () {
                if (_activeMenu != null) {
                  _onMenuItemTapped(0);
                } else {
                  _onMenuItemTapped(2);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Use o botão Iniciar Pedido na Home para carregar o Cardápio.')),
                  );
                }
              },
            ),
            // ATUALIZADO: Ícone de carrinho com contador no Drawer
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Carrinho ($_cartItemCount itens)'),
              selected: _selectedIndex == 1,
              onTap: () => _onMenuItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: _selectedIndex == 2,
              onTap: () => _onMenuItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Comanda'),
              selected: _selectedIndex == 3,
              onTap: () => _onMenuItemTapped(3),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

// ----------------------------------------------------------------------------
// TELA DE CARRINHO (NOVA)
// ----------------------------------------------------------------------------

class CarrinhoScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double cartTotal;
  final Function(String productId) onRemoveItem;

  const CarrinhoScreen({
    super.key,
    required this.cartItems,
    required this.cartTotal,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Seu carrinho está vazio!', style: TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Adicione itens do cardápio para fazer o pedido.', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                  title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('R\$ ${item.subtotal.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => onRemoveItem(item.product.id),
                  ),
                ),
              );
            },
          ),
        ),
        // Rodapé de Confirmação de Pedido
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: R\$ ${cartTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Ação de Confirmação Final do Pedido
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pedido Confirmado! (Próxima etapa: Enviar para API)')),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Confirmar Pedido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// MODAL DE ADICIONAR PRODUTO (NOVO)
// ----------------------------------------------------------------------------

class AddProductModal extends StatefulWidget {
  final Product product;
  final Function(int quantity) onConfirm;

  const AddProductModal({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  _AddProductModalState createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar ao Carrinho', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.product.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Preço unitário: R\$ ${widget.product.price.toStringAsFixed(2)}'),
            const Divider(),
            const Text('Quantidade:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Subtotal: R\$ ${(widget.product.price * _quantity).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
        ElevatedButton(
          onPressed: () => widget.onConfirm(_quantity),
          child: const Text('Confirmar'),
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// TELA DE DETALHES DO CARDÁPIO (MenuDetailScreen - LAYOUT 2 COLUNAS)
// ----------------------------------------------------------------------------

class MenuDetailScreen extends StatefulWidget {
  final Menu menu;
  final Function(Product product) onProductTap; // NOVO: Callback ao tocar no produto

  const MenuDetailScreen({
    super.key,
    required this.menu,
    required this.onProductTap,
  });

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  String _selectedCategoryName = mockCategories.first.name;

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

  Widget _buildProductCard(Product product, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => widget.onProductTap(product), // CHAMA A MODAL!
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant_menu, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.menu.name,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  widget.menu.note,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Divider(height: 20, thickness: 1.5),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockCategories.length,
              itemBuilder: (context, index) {
                final category = mockCategories[index];
                final isSelected = category.name == _selectedCategoryName;

                return ListTile(
                  leading: Icon(
                    _getCategoryIcon(category.icon),
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedCategoryName = category.name;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductArea() {
    final filteredProducts = mockProducts.where(
          (product) => product.categoryName == _selectedCategoryName,
    ).toList();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itens: $_selectedCategoryName',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Divider(height: 20, thickness: 1),

            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                child: Text(
                  'Nenhum produto encontrado nesta categoria.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildProductCard(product, context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildCategoryList(),
        _buildProductArea(),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// TELA DE COMANDA
// ----------------------------------------------------------------------------

class ComandaScreen extends StatelessWidget {
  const ComandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Sua Comanda',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade de Comanda em desenvolvimento.')),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Ver Detalhes da Comanda'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// TELA INICIAL (HOME) COM BOTÃO DE ATALHO
// ----------------------------------------------------------------------------

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
      final List<Menu> menus = await fetchMenus();

      final Menu? activeMenu = menus.isNotEmpty
          ? menus.firstWhere((m) => m.active, orElse: () => menus.first)
          : null;

      if (activeMenu != null) {
        onQuickOrder(activeMenu);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum cardápio disponível para iniciar o pedido.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar Cardápio: ${e.toString().split(':').last.trim()}'),
          duration: const Duration(seconds: 4),
        ),
      );
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
            'Bem-vindo',
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
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lunch_dining,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Clique para Iniciar o Pedido',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// DADOS MOCKADOS E MODELOS (ADICIONADO CARTITEM)
// ----------------------------------------------------------------------------

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}

class ProductCategory {
  final String name;
  final String icon;

  ProductCategory({required this.name, required this.icon});
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryName,
  });
}

// Dados de exemplo para as categorias
final List<ProductCategory> mockCategories = [
  ProductCategory(name: 'Destaques do Chef', icon: 'star'),
  ProductCategory(name: 'Pratos Principais', icon: 'dinner_dining'),
  ProductCategory(name: 'Lanches e Burgers', icon: 'lunch_dining'),
  ProductCategory(name: 'Porções e Petiscos', icon: 'tapas'),
  ProductCategory(name: 'Bebidas', icon: 'local_bar'),
  ProductCategory(name: 'Sobremesas', icon: 'cake'),
];

// DADOS MOCKADOS DE PRODUTOS
final List<Product> mockProducts = [
  // Destaques do Chef
  Product(id: 'p1', name: 'Prato Executivo', description: 'O prato mais pedido, com arroz, feijão, bife e salada.', price: 39.90, categoryName: 'Destaques do Chef'),
  Product(id: 'p2', name: 'Mega Burger Duplo', description: 'Duas carnes, queijo, bacon e maionese especial.', price: 34.50, categoryName: 'Destaques do Chef'),

  // Pratos Principais
  Product(id: 'p3', name: 'Salmão Grelhado', description: 'Salmão fresco com legumes no vapor e azeite.', price: 55.00, categoryName: 'Pratos Principais'),
  Product(id: 'p4', name: 'Picanha com Fritas', description: 'Corte nobre de picanha, acompanha batata frita e vinagrete.', price: 65.00, categoryName: 'Pratos Principais'),

  // Lanches e Burgers
  Product(id: 'p5', name: 'Burger Clássico', description: 'Pão, carne, queijo e alface. Simples e saboroso.', price: 25.00, categoryName: 'Lanches e Burgers'),
  Product(id: 'p6', name: 'Sanduíche Vegano', description: 'Pão integral, hummus, pepino e rúcula.', price: 22.00, categoryName: 'Lanches e Burgers'),

  // Porções e Petiscos
  Product(id: 'p7', name: 'Batata Frita', description: 'Porção grande de batata frita com sal e pimenta.', price: 18.00, categoryName: 'Porções e Petiscos'),
  Product(id: 'p8', name: 'Aipim Frito', description: 'Porção de aipim frito sequinho, acompanha molho rosé.', price: 21.00, categoryName: 'Porções e Petiscos'),

  // Bebidas
  Product(id: 'p9', name: 'Cerveja Artesanal IPA', description: 'Lager encorpada e refrescante. 500ml.', price: 15.00, categoryName: 'Bebidas'),
  Product(id: 'p10', name: 'Suco de Laranja', description: 'Laranja espremida na hora. 300ml.', price: 10.00, categoryName: 'Bebidas'),

  // Sobremesas
  Product(id: 'p11', name: 'Brownie com Sorvete', description: 'Brownie quente de chocolate com uma bola de sorvete de creme.', price: 18.00, categoryName: 'Sobremesas'),
  Product(id: 'p12', name: 'Mousse de Maracujá', description: 'Leve e refrescante mousse de maracujá caseira.', price: 14.00, categoryName: 'Sobremesas'),
];


class Menu {
  final String id;
  final String name;
  final String note;
  final bool active;
  final String theme;

  Menu({
    required this.id,
    required this.name,
    required this.note,
    required this.active,
    required this.theme,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    final String selfLink = json['_links']['self']['href'];
    final String id = selfLink.substring(selfLink.lastIndexOf('/') + 1);

    return Menu(
      id: id,
      name: json['name'] ?? 'Cardápio sem Nome',
      note: json['note'] ?? 'Sem descrição.',
      active: json['active'] ?? false,
      theme: json['theme'] ?? 'Padrão',
    );
  }
}

Future<List<Menu>> fetchMenus() async {
  const url = 'http://10.0.2.2:8080/menus';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> menusJson = data['_embedded']?['menus'] ?? [];

      return menusJson.map((json) => Menu.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar menus. Status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro de conexão: Verifique se a API está rodando em http://localhost:8080.');
  }
}