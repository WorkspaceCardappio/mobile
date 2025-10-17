import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math';

// ----------------------------------------------------------------------------
// 1. APLICATIVO BASE E TEMA
// ----------------------------------------------------------------------------

void main() {
  runApp(const OrderApp());
}

class OrderApp extends StatelessWidget {
  const OrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardappio Profissional',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E1E1E), // Cor principal (Preto)
            primary: const Color(0xDF1E1E1E),
            secondary: const Color(0xEA2C3E50), // Cor secundária para textos/detalhes
            surface: const Color(0xFFFFFFFF), // Cor de fundo de Cards
            background: const Color(0xFFF8F9FA), // Fundo da tela
            onPrimary: Colors.white,
            onBackground: const Color(0xED2C3E50),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xE52C3E50),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Color(0xFF2C3E50)),
            headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: Color(0xFF2C3E50)),
            bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF495057)),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          )
      ),
      home: const MainNavigator(initialIndex: 2),
    );
  }
}

// ----------------------------------------------------------------------------
// 5. FUNÇÕES DE REQUISIÇÃO (API SERVICE) E MODELOS
// (Mantidas no topo para fácil acesso, sem alteração de ordem necessária)
// ----------------------------------------------------------------------------

// -------------------------
// MODELOS GERAIS
// -------------------------

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

class ProductAddOn {
  final String id;
  final String name;
  final double price;

  ProductAddOn({required this.id, required this.name, required this.price});
}

class ProductOption {
  final String id;
  final String name;
  final double priceAdjustment;

  ProductOption({required this.id, required this.name, required this.priceAdjustment});
}

class ProductVariable {
  final String id;
  final String name;
  final List<ProductOption> options;

  ProductVariable({required this.id, required this.name, required this.options});
}

class TicketItem {
  final String productName;
  final int quantity;
  final double unitPrice;

  double get subtotal => unitPrice * quantity;

  TicketItem({required this.productName, required this.quantity, required this.unitPrice});

  factory TicketItem.fromJson(Map<String, dynamic> json) {
    return TicketItem(
      productName: json['productName'] ?? 'Item Desconhecido',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
    );
  }
}

class TicketDetail {
  final String id;
  final int tableNumber;
  final double total;
  final DateTime createdAt;
  final List<TicketItem> items;

  TicketDetail({
    required this.id,
    required this.tableNumber,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    final String selfLink = json['_links']['self']['href'];
    final String id = selfLink.substring(selfLink.lastIndexOf('/') + 1);
    final DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

    final List<dynamic> itemsJson = json['_embedded']?['items'] ?? [];
    final List<TicketItem> items = itemsJson.map((itemJson) => TicketItem.fromJson(itemJson as Map<String, dynamic>)).toList();

    return TicketDetail(
      id: id,
      tableNumber: json['tableNumber'] ?? 0,
      total: (json['total'] ?? 0.0).toDouble(),
      createdAt: createdAt,
      items: items,
    );
  }
}

class Ticket {
  final String id;
  final int tableNumber;
  final double total;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.tableNumber,
    required this.total,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final String selfLink = json['_links']['self']['href'];
    final String id = selfLink.substring(selfLink.lastIndexOf('/') + 1);
    final DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

    return Ticket(
      id: id,
      tableNumber: json['tableNumber'] ?? 0,
      total: (json['total'] ?? 0.0).toDouble(),
      createdAt: createdAt,
    );
  }
}

// -------------------------
// FUNÇÕES DE API MOCKADAS
// -------------------------

Future<List<Menu>> fetchMenus() async {
  const url = 'http://10.0.2.2:8080/menus';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> menusJson = data['_embedded']?['menus'] ?? [];
      return menusJson.map((json) => Menu.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Falha ao carregar menus. Status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro de conexão: Verifique se a API está rodando em http://localhost:8080.');
  }
}

Future<List<Ticket>> fetchTickets() async {
  const url = 'http://10.0.2.2:8080/tickets';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> ticketsJson = data['_embedded']?['tickets'] ?? [];
      return ticketsJson.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Falha ao carregar comandas. Status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro de conexão: Verifique se a API está rodando em http://localhost:8080. (${e.toString()})');
  }
}

Future<TicketDetail> fetchTicketDetails(String ticketId) async {
  await Future.delayed(const Duration(milliseconds: 700));

  final Map<String, dynamic> mockData = {
    'id': ticketId,
    'tableNumber': 5,
    'total': 0.0,
    'createdAt': '2025-10-17T08:00:00.000Z',
    '_links': {'self': {'href': 'http://localhost:8080/tickets/$ticketId'}},
    '_embedded': {
      'items': [
        {'productName': 'Picanha com Fritas', 'quantity': 1, 'unitPrice': 65.00},
        {'productName': 'Cerveja Artesanal IPA', 'quantity': 4, 'unitPrice': 15.00},
        {'productName': 'Batata Frita', 'quantity': 1, 'unitPrice': 12.90},
      ],
    },
  };

  final items = (mockData['_embedded']!['items'] as List<dynamic>)
      .map((i) => TicketItem.fromJson(i as Map<String, dynamic>)).toList();

  double calculatedTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
  mockData['total'] = calculatedTotal;

  return TicketDetail.fromJson(mockData);
}

Future<bool> payTicket(String ticketId) async {
  await Future.delayed(const Duration(seconds: 1));
  return DateTime.now().millisecondsSinceEpoch % 10 < 9;
}

// -------------------------
// DADOS MOCKADOS
// -------------------------

final List<ProductAddOn> mockAddOns = [
  ProductAddOn(id: 'a1', name: 'Bacon Extra', price: 5.00),
  ProductAddOn(id: 'a2', name: 'Molho Especial', price: 3.50),
  ProductAddOn(id: 'a3', name: 'Cebola Caramelizada', price: 4.00),
];

final List<ProductVariable> mockVariables = [
  ProductVariable(
    id: 'v1',
    name: 'Tamanho',
    options: [
      ProductOption(id: 'op1', name: 'Pequeno (300ml)', priceAdjustment: -5.00),
      ProductOption(id: 'op2', name: 'Médio (500ml)', priceAdjustment: 0.00),
      ProductOption(id: 'op3', name: 'Grande (700ml)', priceAdjustment: 3.00),
    ],
  ),
];

final List<ProductCategory> mockCategories = [
  ProductCategory(name: 'Destaques do Chef', icon: 'star'),
  ProductCategory(name: 'Pratos Principais', icon: 'dinner_dining'),
  ProductCategory(name: 'Lanches e Burgers', icon: 'lunch_dining'),
  ProductCategory(name: 'Porções e Petiscos', icon: 'tapas'),
  ProductCategory(name: 'Bebidas', icon: 'local_bar'),
  ProductCategory(name: 'Sobremesas', icon: 'cake'),
];

final List<Product> mockProducts = [
  Product(id: 'p1', name: 'Prato Executivo', description: 'O prato mais pedido, com arroz, feijão, bife e salada.', price: 39.90, categoryName: 'Destaques do Chef'),
  Product(id: 'p2', name: 'Mega Burger Duplo', description: 'Duas carnes, queijo, bacon e maionese especial.', price: 34.50, categoryName: 'Destaques do Chef'),
  Product(id: 'p3', name: 'Salmão Grelhado', description: 'Salmão fresco com legumes no vapor e azeite.', price: 55.00, categoryName: 'Pratos Principais'),
  Product(id: 'p4', name: 'Picanha com Fritas', description: 'Corte nobre de picanha, acompanha batata frita e vinagrete.', price: 65.00, categoryName: 'Pratos Principais'),
  Product(id: 'p5', name: 'Burger Clássico', description: 'Pão, carne, queijo e alface. Simples e saboroso.', price: 25.00, categoryName: 'Lanches e Burgers'),
  Product(id: 'p6', name: 'Sanduíche Vegano', description: 'Pão integral, hummus, pepino e rúcula.', price: 22.00, categoryName: 'Lanches e Burgers'),
  Product(id: 'p7', name: 'Batata Frita', description: 'Porção grande de batata frita com sal e pimenta.', price: 18.00, categoryName: 'Porções e Petiscos'),
  Product(id: 'p8', name: 'Aipim Frito', description: 'Porção de aipim frito sequinho, acompanha molho rosé.', price: 21.00, categoryName: 'Porções e Petiscos'),
  Product(id: 'p9', name: 'Cerveja Artesanal IPA', description: 'Lager encorpada e refrescante. 500ml.', price: 15.00, categoryName: 'Bebidas'),
  Product(id: 'p10', name: 'Suco de Laranja', description: 'Laranja espremida na hora. 300ml.', price: 10.00, categoryName: 'Bebidas'),
  Product(id: 'p11', name: 'Brownie com Sorvete', description: 'Brownie quente de chocolate com uma bola de sorvete de creme.', price: 18.00, categoryName: 'Sobremesas'),
  Product(id: 'p12', name: 'Mousse de Maracujá', description: 'Leve e refrescante mousse de maracujá caseira.', price: 14.00, categoryName: 'Sobremesas'),
];

// ----------------------------------------------------------------------------
// 7. WIDGET DE SIDEBAR PERMANENTE (Definido antes do MainNavigator)
// ----------------------------------------------------------------------------

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
    const Color onPrimaryColor = Colors.white;

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
          // Header da Sidebar
          Container(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0),
            width: double.infinity,
            color: primaryColor,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),

          // Itens de Navegação
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8.0),
              children: <Widget>[
                _buildSidebarItem(context, 0, Icons.menu_book, 'Cardápio', selectedIndex, onTap, primaryColor),
                _buildSidebarItem(context, 1, Icons.shopping_cart, 'Carrinho ($cartItemCount)', selectedIndex, onTap, primaryColor),
                _buildSidebarItem(context, 2, Icons.home, 'Home', selectedIndex, onTap, primaryColor),
                _buildSidebarItem(context, 3, Icons.receipt_long, 'Comanda', selectedIndex, onTap, primaryColor),
                _buildSidebarItem(context, 4, Icons.payment, 'Pagamento', selectedIndex, onTap, primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// WIDGET AUXILIAR PARA CRIAR OS ITENS DA SIDEBAR
Widget _buildSidebarItem(
    BuildContext context,
    int index,
    IconData icon,
    String title,
    int selectedIndex,
    Function(int) onTap,
    Color primaryColor,
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

// ----------------------------------------------------------------------------
// TELAS DE CONTEÚDO (Definidas antes do MainNavigator)
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

class CartScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double cartTotal;
  final Function(String productId) onRemoveItem;
  final VoidCallback onConfirmOrder;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.cartTotal,
    required this.onRemoveItem,
    required this.onConfirmOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Seu carrinho está vazio!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ),
                  title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                  subtitle: Text('Preço Unitário: R\$ ${item.product.price.toStringAsFixed(2)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('R\$ ${item.subtotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.secondary)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                        onPressed: () => onRemoveItem(item.product.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Remover Item',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              Text(
                'R\$ ${cartTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConfirmOrder,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Finalizar e Enviar Pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  double _currentPrice = 0.0;

  Map<String, bool> _selectedAddOns = {};
  String? _selectedVariableValue;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.product.price;
    for (var addon in mockAddOns) {
      _selectedAddOns[addon.id] = false;
    }
    if (mockVariables.isNotEmpty) {
      _selectedVariableValue = mockVariables.first.options.first.id;
      _currentPrice += mockVariables.first.options.first.priceAdjustment;
    }
    _updateTotal();
  }

  void _updateTotal() {
    double basePrice = widget.product.price;

    if (_selectedVariableValue != null) {
      final selectedOption = mockVariables.expand((v) => v.options).firstWhere(
            (opt) => opt.id == _selectedVariableValue,
        orElse: () => ProductOption(id: '', name: '', priceAdjustment: 0.0),
      );
      basePrice += selectedOption.priceAdjustment;
    }

    for (var addon in mockAddOns) {
      if (_selectedAddOns[addon.id] == true) {
        basePrice += addon.price;
      }
    }

    setState(() {
      _currentPrice = basePrice;
    });
  }

  Widget _buildAddOnsSection() {
    if (mockAddOns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        Text('Adicionais (Opcional)', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
        const SizedBox(height: 10),
        ...mockAddOns.map((addon) {
          return CheckboxListTile(
            title: Text('${addon.name} (+ R\$ ${addon.price.toStringAsFixed(2)})'),
            value: _selectedAddOns[addon.id],
            onChanged: (bool? newValue) {
              setState(() {
                _selectedAddOns[addon.id] = newValue!;
                _updateTotal();
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildVariablesSection() {
    if (mockVariables.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        Text(
            'Opções Variáveis: Tamanho/Sabor (Obrigatório)',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)
        ),
        const SizedBox(height: 10),
        ...mockVariables.first.options.map((option) {
          return RadioListTile<String>(
            title: Text('${option.name} (R\$ ${option.priceAdjustment >= 0 ? '+' : '-'} ${option.priceAdjustment.abs().toStringAsFixed(2)})'),
            value: option.id,
            groupValue: _selectedVariableValue,
            onChanged: (String? value) {
              setState(() {
                _selectedVariableValue = value;
                _updateTotal();
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 1,
      ),
      body: Row(
        children: [
          Expanded(
            flex: isLargeScreen ? 3 : 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(widget.product.description, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                  const SizedBox(height: 16),

                  _buildVariablesSection(),

                  _buildAddOnsSection(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 30),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 30),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, {
                'quantity': _quantity,
                'total_item': (_currentPrice * _quantity),
                'addons': _selectedAddOns.entries.where((e) => e.value).map((e) => e.key).toList(),
                'variable': _selectedVariableValue,
              });
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: Text('Adicionar R\$ ${(_currentPrice * _quantity).toStringAsFixed(2)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuDetailScreen extends StatefulWidget {
  final Menu menu;
  final Function(Product product) onProductTap;

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
        onTap: () => widget.onProductTap(product),
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
              '$_selectedCategoryName',
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

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  Future<List<Ticket>>? _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = fetchTickets();
  }

  void _reloadTickets() {
    setState(() {
      _ticketsFuture = fetchTickets();
    });
  }

  // NOVA FUNÇÃO: Navega para a tela de detalhes da comanda
  void _openTicketDetails(Ticket ticket) async {
    final bool? shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailScreen(ticket: ticket, onNavigateToPayment: _navigateToPaymentWithTicket),
      ),
    );

    if (shouldReload == true) {
      _reloadTickets();
    }
  }

  // Função passada para TicketDetailScreen para abrir a PaymentScreen
  void _navigateToPaymentWithTicket(Ticket ticket) {
    // 💡 AQUI FAZEMOS O PUSH PARA A PaymentScreen, pré-selecionando a comanda
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(preSelectedTicket: ticket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comandas Abertas',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 28),
                onPressed: _reloadTickets,
                tooltip: 'Recarregar Comandas',
              ),
            ],
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child: FutureBuilder<List<Ticket>>(
            future: _ticketsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
                        const SizedBox(height: 15),
                        Text(
                          'Erro ao Carregar Comandas.',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Detalhes: ${snapshot.error.toString().split(':').last.trim()}',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: _reloadTickets,
                          icon: const Icon(Icons.replay),
                          label: const Text('Tentar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 100, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('Nenhuma Comanda Aberta.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Inicie um pedido na Home para criar uma comanda.', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              final tickets = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
                  final formattedDate = dateFormat.format(ticket.createdAt);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(ticket.tableNumber.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('Comanda #${ticket.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('Mesa: ${ticket.tableNumber} - Total: R\$ ${ticket.total.toStringAsFixed(2)}\nAberta em: $formattedDate'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.secondary),
                      onTap: () => _openTicketDetails(ticket),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  final Function(Ticket ticket) onNavigateToPayment; // Callback

  const TicketDetailScreen({super.key, required this.ticket, required this.onNavigateToPayment});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Future<TicketDetail>? _ticketDetailFuture;

  @override
  void initState() {
    super.initState();
    _ticketDetailFuture = fetchTicketDetails(widget.ticket.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comanda #${widget.ticket.id} - Mesa ${widget.ticket.tableNumber}', style: const TextStyle(fontSize: 18)),
        elevation: 1,
      ),
      body: FutureBuilder<TicketDetail>(
        future: _ticketDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar detalhes: ${snapshot.error.toString().split(':').last.trim()}', textAlign: TextAlign.center),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Detalhes da comanda não encontrados.'));
          }

          final detail = snapshot.data!;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
          final formattedDate = dateFormat.format(detail.createdAt);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data de Abertura: $formattedDate', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text('Total da Comanda:', style: Theme.of(context).textTheme.titleLarge),
                    Text('R\$ ${detail.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Itens Pedidos (${detail.items.length}):', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: detail.items.length,
                  itemBuilder: (context, index) {
                    final item = detail.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          child: Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
                        ),
                        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('R\$ ${item.unitPrice.toStringAsFixed(2)} / un.'),
                        trailing: Text(
                          'R\$ ${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
                ),
                child: ElevatedButton.icon(
                  // CHAMA O CALLBACK QUE NAVEGA PARA A PaymentScreen
                  onPressed: () => widget.onNavigateToPayment(widget.ticket),
                  icon: const Icon(Icons.payment),
                  label: Text('Pagar Comanda (R\$ ${detail.total.toStringAsFixed(2)})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  // Recebe a comanda pré-selecionada (opcional)
  final Ticket? preSelectedTicket;

  const PaymentScreen({super.key, this.preSelectedTicket});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<List<Ticket>>? _ticketsFuture;
  Ticket? _selectedTicket;
  String _paymentOption = 'total';
  double _partialAmount = 0.0;
  final TextEditingController _partialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticketsFuture = fetchTickets();
    _selectedTicket = widget.preSelectedTicket;

    if (_selectedTicket != null) {
      _partialAmount = _selectedTicket!.total;
      _partialController.text = _partialAmount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _partialController.dispose();
    super.dispose();
  }

  void _updatePartialAmount(double total) {
    setState(() {
      _partialAmount = total;
      _partialController.text = total.toStringAsFixed(2);
    });
  }

  void _handlePaymentProcessing() async {
    if (_selectedTicket == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma comanda primeiro.')));
      return;
    }

    double amountToPay = 0.0;
    if (_paymentOption == 'total') {
      amountToPay = _selectedTicket!.total;
    } else {
      amountToPay = double.tryParse(_partialController.text.replaceAll(',', '.')) ?? 0.0;
      if (amountToPay <= 0 || amountToPay > _selectedTicket!.total) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valor parcial inválido.')));
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Processando pagamento de R\$ ${amountToPay.toStringAsFixed(2)} para Comanda #${_selectedTicket!.id}...'),
    ));

    final result = await payTicket(_selectedTicket!.id);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Pagamento realizado com sucesso!')));

      // Se for pagamento total, remove a comanda da lista
      if (_paymentOption == 'total') {
        setState(() {
          _selectedTicket = null;
          _ticketsFuture = fetchTickets();
        });
      }

      // Se veio da tela de detalhes, fecha a PaymentScreen.
      if (widget.preSelectedTicket != null && Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Falha na transação. Tente novamente.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processar Pagamento'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Erro ao carregar comandas: ${snapshot.error}'));
          }

          final availableTickets = snapshot.data!;

          // Garante que a comanda pré-selecionada ainda exista na lista
          if (widget.preSelectedTicket != null && _selectedTicket == null) {
            _selectedTicket = availableTickets.firstWhere(
                  (t) => t.id == widget.preSelectedTicket!.id,
              orElse: () => availableTickets.isNotEmpty ? availableTickets.first : null as Ticket,
            );
            if (_selectedTicket != null) {
              _updatePartialAmount(_selectedTicket!.total);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Seleção da Comanda
                Text('1. Selecione a Comanda', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                DropdownButtonFormField<Ticket>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    labelText: 'Comanda a Pagar',
                  ),
                  value: _selectedTicket,
                  items: availableTickets.map((ticket) {
                    return DropdownMenuItem(
                      value: ticket,
                      child: Text('Mesa ${ticket.tableNumber} - Total: R\$ ${ticket.total.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                  onChanged: (Ticket? newValue) {
                    setState(() {
                      _selectedTicket = newValue;
                      if (_selectedTicket != null) {
                        _updatePartialAmount(_selectedTicket!.total);
                        _paymentOption = 'total';
                      }
                    });
                  },
                  hint: const Text('Selecione uma comanda'),
                ),
                const Divider(height: 40),

                // 2. Opção de Pagamento
                Text('2. Tipo de Pagamento', style: Theme.of(context).textTheme.titleLarge),

                if (_selectedTicket != null) ...[
                  RadioListTile<String>(
                    title: Text('Pagamento Total (R\$ ${_selectedTicket!.total.toStringAsFixed(2)})'),
                    value: 'total',
                    groupValue: _paymentOption,
                    onChanged: (value) => setState(() {
                      _paymentOption = value!;
                      _updatePartialAmount(_selectedTicket!.total);
                    }),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<String>(
                    title: const Text('Pagamento Parcial'),
                    value: 'partial',
                    groupValue: _paymentOption,
                    onChanged: (value) => setState(() => _paymentOption = value!),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],

                // 3. Valor Parcial (Se selecionado)
                if (_paymentOption == 'partial' && _selectedTicket != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextFormField(
                      controller: _partialController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        // Permite apenas números e opcionalmente uma vírgula/ponto
                        // (Em um app real usaria um MaskedInputFormatter)
                      ],
                      decoration: InputDecoration(
                        labelText: 'Valor a Pagar (Máx: R\$ ${_selectedTicket!.total.toStringAsFixed(2)})',
                        prefixText: 'R\$ ',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                // 4. Botão de Finalizar Pagamento
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedTicket != null ? _handlePaymentProcessing : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      _selectedTicket == null
                          ? 'Selecione a Comanda'
                          : (_paymentOption == 'total' ? 'Finalizar Pagamento Total' : 'Pagar R\$ ${_partialController.text}'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// 2. NAVEGADOR PRINCIPAL (Corrigido para ordem)
// ----------------------------------------------------------------------------

class MainNavigator extends StatefulWidget {
  final int initialIndex;
  const MainNavigator({super.key, this.initialIndex = 0});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> with _CartManager, _NavigationManager {
  Menu? _activeMenu;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // 💡 AQUI AS CLASSES JÁ FORAM DEFINIDAS ACIMA, EVITANDO ERROS DE ESCOPO
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

  void _handleQuickOrder(Menu menu) {
    setState(() {
      _activeMenu = menu;
      _selectedIndex = 0;
      _screens[0] = _buildCurrentMenuScreen();
    });
  }

  void _handleOrderConfirmation() {
    setState(() {
      _cartItems = [];
      _screens[1] = _buildCartScreen();
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

  @override
  Widget build(BuildContext context) {
    _screens[0] = _buildCurrentMenuScreen();
    _screens[1] = _buildCartScreen();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cardappio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        elevation: 4,
        actions: [
          Stack(
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
          ),
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
                  const SnackBar(content: Text('Use "Iniciar Pedido" na Home para carregar o Cardápio.')),
                );
              } else {
                _onMenuItemTapped(index);
              }
            },
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Extensão para gerenciar a Lógica de Navegação
mixin _NavigationManager on State<MainNavigator> {
  late int _selectedIndex;
  late List<Widget> _screens;

  void _onMenuItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Extensão para gerenciar a Lógica do Carrinho
mixin _CartManager on State<MainNavigator> {
  List<CartItem> _cartItems = [];
  double get _cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  int get _cartItemCount => _cartItems.length;

  void _addItemToCart(Product product, int quantity) {
    setState(() {
      final newItem = CartItem(product: product, quantity: quantity);
      final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex].quantity += quantity;
      } else {
        _cartItems.add(newItem);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ ${quantity}x ${product.name} adicionado ao carrinho!')),
    );
  }

  void _removeItemFromCart(String productId) {
    setState(() {
      _cartItems.removeWhere((item) => item.product.id == productId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removido do carrinho.')),
    );
  }
}