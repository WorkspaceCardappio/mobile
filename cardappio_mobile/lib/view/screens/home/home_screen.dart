import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as caro;

import '../../../data/api_service.dart';
import '../../../model/menu.dart';

class MenuItem {
  final String name;
  final String imageUrl;
  final String price;

  MenuItem({required this.name, required this.imageUrl, required this.price});
}

final List<MenuItem> promoItemsList = [
  MenuItem(
      name: 'Bife Grelhado com Tomate Cereja',
      imageUrl: 'lib/images/prato.jpeg',
      price: 'R\$ 54,99'),
  MenuItem(
      name: 'Camarão Crocante ao Molho',
      imageUrl: 'lib/images/camarao.jpeg',
      price: 'R\$ 68,50'),
  MenuItem(
      name: 'Macarrão com Frutos do Mar',
      imageUrl: 'lib/images/macarrao.jpeg',
      price: 'R\$ 59,90'),
  MenuItem(
      name: 'Prato Feito Executivo',
      imageUrl: 'lib/images/pf.jpeg',
      price: 'R\$ 38,90'),
];

final MenuItem promoItem = promoItemsList[0];

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

class HomeScreen extends StatefulWidget {
  final Function(Menu menu) onQuickOrder;

  const HomeScreen({super.key, required this.onQuickOrder});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activePage = 0;
  final caro.CarouselSliderController _carouselController = caro.CarouselSliderController(); 

 @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
        widget.onQuickOrder(activeMenu);
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

  Widget _buildPromotionalCarouselItem(BuildContext context, MenuItem item, int index) {

    bool active = index == _activePage;
    double marginVertical = active ? 10 : 20;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: marginVertical), 
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item.imageUrl, 
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color.fromARGB(255, 182, 13, 13),
                alignment: Alignment.center,
                child: const Text(
                  'Erro de Imagem',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),

          Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0), // Transparente no topo
                  Colors.black.withOpacity(0.2), 
                  Colors.black.withOpacity(0.5), // Mais escuro na base
                  Colors.black.withOpacity(0.7), 
                ],
                stops: const [0.0, 0.5, 0.8, 1.0],
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
                  shadows: [
                  Shadow(offset: Offset(2, 2), blurRadius: 4.0, color: Colors.black)
                ]
                ),
              ),
            ),

             Positioned(
              bottom: 10, 
              left: 16, 
              child: Text(
                item.price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(offset: Offset(1, 1), blurRadius: 3.0, color: Colors.black54)
                  ]
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
                child: const Text('Adicionar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

           
          ],
        ),
      );
  }

List<Widget> _buildPageIndicators() {
    return List<Widget>.generate(promoItemsList.length, (index) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: _activePage == index ? 10.0 : 8.0,
        height: _activePage == index ? 10.0 : 8.0,
        decoration: BoxDecoration(
            color: _activePage == index ? Colors.black : Colors.black.withOpacity(0.6),
            shape: BoxShape.circle),
      );
    });
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
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        const SizedBox(height: 10),

        //carrossel
         SizedBox(
            height: MediaQuery.of(context).size.height * 0.55, 
            width: screenWidth,
          child: Column(
            children: [
              Expanded(
                    child: caro.CarouselSlider.builder(
                      carouselController: _carouselController,
                      itemCount: promoItemsList.length,
                      options: caro.CarouselOptions(
                        height: double.infinity,
                        viewportFraction: 0.7,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        enlargeCenterPage: true,

                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      
                        onPageChanged: (index, reason) {
                          setState(() {
                            _activePage = index;
                          });
                        },
                        enlargeFactor: 0.3,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final item = promoItemsList[index];
                        return _buildPromotionalCarouselItem(context, item, index);
                      },
                  ),
                  ),

               Padding(
                 padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicators(),
                  ),
               ),
              ],
            ),
         ),
              
              const SizedBox(height: 10),

        //recomendações da casa     
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