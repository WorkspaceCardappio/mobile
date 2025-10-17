import 'package:cardappio_mobile/ticket_screen/widgets/ticket_cards.dart';
import 'package:cardappio_mobile/ticket_screen/widgets/side_bar.dart';
import 'package:flutter/material.dart';

class TicketGridScreen extends StatelessWidget {
  const TicketGridScreen({super.key});

  final List<Map<String, dynamic>> orders = const [
    {'number': '001', 'name': 'Lorenzo Bernozzi', 'price': '130,99', 'color': Color(0xFFE6E8B6)}, 
    {'number': '002', 'name': 'Lorenzo Bernozzi', 'price': '130,99', 'color': Color(0xFFE6E8B6)}, 
    {'number': '003', 'name': 'Lorenzo Bernozzi', 'price': '130,99', 'color': Color(0xFFA5D6A7)}, 
    {'number': '004', 'name': 'Lorenzo Bernozzi', 'price': '130,99', 'color': Color(0xFFA5D6A7)}, 
    {'number': '005', 'name': 'Lorenzo Bernozzi', 'price': '130,99', 'color': Color(0xFFF8A8A8)}, 
    {'number': '006', 'name': 'Lorenzo Bernozzi', 'price': '130,99', 'color': Color(0xFFF8A8A8)}, 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          const SideBar(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      itemCount: orders.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        crossAxisSpacing: 30, 
                        mainAxisSpacing: 50, 
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(
                          number: order['number'],
                          name: order['name'],
                          price: order['price'],
                          color: order['color'],
                        );
                      },
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildLegendItem(Color(0xFFA5D6A7), 'Finalizada'),
                        const SizedBox(width: 20),
                        _buildLegendItem(Color(0xFFF8A8A8), 'Cancelada'),
                        const SizedBox(width: 20),
                        _buildLegendItem(Color(0xFFE6E8B6), 'Aberta'), 
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'Cardappio',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 40),
      ),
      backgroundColor: Color(0xFF2E2E33), 
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Row(
            children: [
              const Text(
                'Mesa 01',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),

              ),
              const SizedBox(width: 50),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
                color: Colors.white,
                style: IconButton.styleFrom(
                  iconSize: 30,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }
}