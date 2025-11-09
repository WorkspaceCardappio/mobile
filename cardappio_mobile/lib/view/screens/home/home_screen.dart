import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as caro;
import '../../../data/api_service.dart';
import '../../../model/menu.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MenuItem {
  final String name;
  final String imageUrl;
  final String price;

  MenuItem({required this.name, required this.imageUrl, required this.price});
}


final List<MenuItem> promoItemsList = [

  MenuItem(name: 'Prato Feito Executivo', imageUrl: 'https://blog-parceiros.ifood.com.br/wp-content/uploads/2022/08/prato-executivo.jpg', price: 'R\$ 38,90'),
  MenuItem(name: 'Bife Grelhado', imageUrl: 'https://static.vecteezy.com/ti/fotos-gratis/p2/3723619-grelhado-fatiado-cap-alcatra-bife-com-dois-copos-de-cerveja-na-madeira-tabua-de-marmore-carne-bife-picanha-brasileira-foto.jpg', price: 'R\$ 54,99'),
  MenuItem(name: 'Camarão Crocante', imageUrl: 'https://www.comidaereceitas.com.br/img/sizeswp/1200x675/2020/02/camarao_frito.jpg', price: 'R\$ 68,50'),
  MenuItem(name: 'Macarrão Frutos do Mar', imageUrl: 'https://www.buaizalimentos.com.br/uploads/receitas/Foto_agenda_2021___massa_frutos_do_mar_74079755_XL__002.jpg', price: 'R\$ 59,90'),

];

final List<MenuItem> houseRecommendations = [

  MenuItem(name: 'Carne Grelhada c/ Batata', imageUrl: 'https://i.panelinha.com.br/i1/bk-2979-carne-de-panela-com-cenoura-e-batata-na-pressao.webp', price: 'R\$ 47,99'),
  MenuItem(name: 'Salmão Grelhado', imageUrl: 'https://www.comidaereceitas.com.br/wp-content/uploads/2020/03/Salmao-assado-no-forno-freepik-780x520.jpg', price: 'R\$ 75,00'),
  MenuItem(name: 'Tiramisù Italiano', imageUrl: 'https://cdn.casaeculinaria.com/wp-content/uploads/2023/03/15114930/Tiramisu.jpg', price: 'R\$ 22,50'),
  MenuItem(name: 'Sopa Cremosa', imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlR9ibYhTdIfgWGiiQNUpkS5uO1Ya1XlaK9g&s', price: 'R\$ 35,00'),

];

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
  int _activePage = 0;
  final caro.CarouselSliderController _carouselController = caro.CarouselSliderController();

  @override
  void initState() {
    super.initState();
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
      overlay.remove();
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }


  Widget _buildConditionalImage(String imageUrl) {

    final bool isNetworkImage = imageUrl.startsWith('http');

    if (isNetworkImage) {

      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
            color: Colors.grey.shade900,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Colors.white)),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade800,
          alignment: Alignment.center,
          child: const Icon(Icons.signal_wifi_off, color: Colors.white70, size: 50),
        ),
      );
    } else {

      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade800,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, color: Colors.white70, size: 50),
        ),
      );
    }
  }



  Widget _buildPromotionalCarouselItem(BuildContext context, MenuItem item, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [

            _buildConditionalImage(item.imageUrl),


            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.4, 0.8, 1.0],
                  ),
                ),
              ),
            ),


            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(offset: Offset(1, 1), blurRadius: 3.0, color: Colors.black)
                        ]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.price,
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(offset: Offset(1, 1), blurRadius: 2.0, color: Colors.black54)
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _handleQuickOrder(context),
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        label: const Text('Pedir Agora', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          elevation: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecommendationCard(BuildContext context, MenuItem item, Function onTap, double itemWidth) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: itemWidth,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),

                  child: _buildConditionalImage(item.imageUrl),
                ),
              ),


              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.price,
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.arrow_circle_right,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  List<Widget> _buildPageIndicators() {
    final colorScheme = Theme.of(context).colorScheme;
    return List<Widget>.generate(promoItemsList.length, (index) {
      return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: _activePage == index ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
              color: _activePage == index ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4))
      );});
  }


  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16.0;
    const double itemSpacing = 16.0;
    final double screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    return Column(
      children: [


        SizedBox(
          height: screenHeight * 0.55,
          child: Column(
            children: [
              Expanded(
                child: caro.CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: promoItemsList.length,
                  options: caro.CarouselOptions(
                    height: double.infinity,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _activePage = index;
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final item = promoItemsList[index];
                    return _buildPromotionalCarouselItem(context, item, index);
                  },
                ),
              ),


              Container(
                color: colorScheme.background,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicators(),
                  ),
                ),
              ),
            ],
          ),
        ),


        Expanded(
          child: Container(

            color: colorScheme.background,
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flash_on_rounded,
                        color: colorScheme.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 8),

                      Text(
                        'OFERTAS ESPECIAIS',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double visibleCards = 2.2;
                        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
                        final totalSpacing = itemSpacing * (visibleCards - 1);
                        final itemWidth = (availableWidth - totalSpacing) / visibleCards;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                          scrollDirection: Axis.horizontal,
                          itemCount: houseRecommendations.length,
                          itemBuilder: (context, index) {
                            final item = houseRecommendations[index];

                            return _buildRecommendationCard(
                                context,
                                item,
                                    () => _handleQuickOrder(context),
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