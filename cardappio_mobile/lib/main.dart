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
// TELA BASE COM DRAWER E TROCA DE TELA
// ----------------------------------------------------------------------------

class BaseScreen extends StatefulWidget {
  final int initialIndex;
  const BaseScreen({super.key, this.initialIndex = 0});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  // ATUALIZAÇÃO DOS ÍNDICES: 0: Cardápio, 1: Carrinho, 2: Home, 3: Comanda
  late int _selectedIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // 2. ATUALIZAÇÃO DA LISTA DE TELAS
    _screens = [
      const MenuScreen(),
      const Center(child: Text('Tela do Carrinho (Em Breve)')),
      HomeScreen(onNavigateToMenu: _onMenuItemTapped),
      const ComandaScreen(), // 1. NOVA TELA DE COMANDA NO ÍNDICE 3
    ];
  }

  void _onMenuItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Fecha o Drawer se estiver aberto
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardappio - Pedido de Mesa', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Cabeçalho do Drawer
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
            // Opções de Navegação
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Cardápio'),
              selected: _selectedIndex == 0,
              onTap: () => _onMenuItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Carrinho'),
              selected: _selectedIndex == 1,
              onTap: () => _onMenuItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: _selectedIndex == 2,
              onTap: () => _onMenuItemTapped(2),
            ),
            // 3. NOVO ITEM DE MENU PARA COMANDA (ÍNDICE 3)
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Comanda'),
              selected: _selectedIndex == 3,
              onTap: () => _onMenuItemTapped(3),
            ),
            // Futuramente: Dividir Comanda
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

// ----------------------------------------------------------------------------
// TELA DE COMANDA (NOVA)
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
            const SizedBox(height: 10),
            Text(
              'Acompanhe seus pedidos, o status de preparo e o valor total.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Ação futura: mostrar resumo da comanda atual
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
  final Function(int index) onNavigateToMenu;

  const HomeScreen({super.key, required this.onNavigateToMenu});

  void _handleQuickOrder(BuildContext context) async {
    try {
      final List<Menu> menus = await fetchMenus();

      final Menu? activeMenu = menus.isNotEmpty
          ? menus.firstWhere((m) => m.active, orElse: () => menus.first)
          : null;

      if (activeMenu != null) {
        onNavigateToMenu(0); // Navega para a MenuScreen (índice 0)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Iniciando pedido no Cardápio: ${activeMenu.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
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
          content: Text('Erro: ${e.toString().split(':').last.trim()}'),
          duration: const Duration(seconds: 4),
        ),
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
// MODELO DE DADOS DA API E FUNÇÃO DE BUSCA (GLOBAL)
// ----------------------------------------------------------------------------

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
    throw Exception('Erro de conexão: Verifique se a API está rodando em http://localhost:8080. Detalhe: $e');
  }
}


// ----------------------------------------------------------------------------
// TELA DE LISTAGEM DE CARDÁPIOS (MenuScreen)
// ----------------------------------------------------------------------------

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<Menu>> _futureMenus;

  @override
  void initState() {
    super.initState();
    _futureMenus = fetchMenus();
  }

  void _onMenuTapped(BuildContext context, Menu menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Clicou no Cardápio: ${menu.name}. (Ir para tela Selecionar Itens)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Categorias de Cardápio',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Menu>>(
            future: _futureMenus,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 10),
                        const Text('Não foi possível conectar à API.', style: TextStyle(color: Colors.red, fontSize: 16)),
                        Text('Detalhe: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _futureMenus = fetchMenus();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Nenhum cardápio ativo encontrado.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                );
              } else {
                final menus = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300.0,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    return _buildMenuCard(context, menu);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, Menu menu) {
    IconData getMenuIcon(String theme) {
      if (menu.name.toLowerCase().contains('executivo')) return Icons.work;
      if (menu.name.toLowerCase().contains('bebidas')) return Icons.local_bar;
      if (menu.name.toLowerCase().contains('sobremesas')) return Icons.cake;
      if (menu.name.toLowerCase().contains('pizza')) return Icons.local_pizza;
      if (menu.name.toLowerCase().contains('lanche')) return Icons.lunch_dining;
      return Icons.restaurant_menu;
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _onMenuTapped(context, menu),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              getMenuIcon(menu.name),
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                menu.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                menu.note,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}