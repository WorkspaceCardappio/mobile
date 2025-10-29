import 'package:flutter/material.dart';

import '../../../data/api_service.dart';
import '../../../model/menu.dart';

class MenuItem {
  final String name;
  final String imageUrl;
  final String price;

  MenuItem({required this.name, required this.imageUrl, required this.price});
}

final MenuItem promoItem = MenuItem(
  name: 'Bife Grelhado com Tomate Cereja',
  imageUrl: 'lib/images/prato.jpeg',
  price: 'R\$ 54,99', 
);

final List<MenuItem> houseRecommendations = [
  MenuItem(
      name: 'Carne Grelhada com Batata',
      imageUrl: 'lib/images/prato.jpeg',
      price: 'R\$ 47,99'),
  MenuItem(
      name: 'Carne Grelhada com Batata',
      imageUrl: 'lib/images/prato.jpeg',
      price: 'R\$ 47,99'),
  MenuItem(
      name: 'Carne Grelhada com Batata',
      imageUrl: 'lib/images/prato.jpeg',
      price: 'R\$ 47,99'),
];

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

  Widget _buildPromotionalSection(BuildContext context, MenuItem item) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: 380,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.imageUrl, 
                width: 800,
                height: 400,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 800,
                  height: 400,
                  color: const Color.fromARGB(255, 182, 13, 13),
                  alignment: Alignment.center,
                  child: Text(
                    'Erro ao carregar imagem: ${item.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              child: Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () => _handleQuickOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51CF66),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text('Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, MenuItem item, Function onTap, double itemWidth) {
    const double cardSpacing = 20.0; 

    return Padding(
      padding: const EdgeInsets.only(right: cardSpacing), 
      child: Container(
        width: itemWidth, 
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  item.imageUrl, 
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade400,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( 
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ), 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text( 
                    item.price,
                    style: const TextStyle(
                      color: Color(0xFF51CF66), 
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
@override
  Widget build(BuildContext context) { 
    const double horizontalPadding = 50.0; 
    const double itemSpacing = 20.0;    
    const int itemsInView = 3;         
    
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55, 
          child: _buildPromotionalSection(context, promoItem),
        ),
        const SizedBox(height: 5),
    
        Expanded(
          child: Container(
            color: const Color(0xFF7c7973),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: horizontalPadding, top: 5.0, bottom: 12),
                  child: const Text(
                    'Recomendações da casa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.31,
                  width: MediaQuery.of(context).size.width,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth - (horizontalPadding * 2); 
                      
                      final totalSpacing = itemSpacing * (itemsInView - 1); 
                      
                      final itemWidth = (availableWidth - totalSpacing) / itemsInView;
                      
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                        scrollDirection: Axis.horizontal,
                        itemCount: houseRecommendations.length,
                        itemBuilder: (context, index) {
                          final item = houseRecommendations[index];
                          
                          return _buildRecommendationCard(
                            context, 
                            item, 
                            () => print('Item ${item.name} clicado'),
                            itemWidth 
                          );
                        },
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}