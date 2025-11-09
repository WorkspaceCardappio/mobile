import 'package:flutter/material.dart';
import '../../../model/cart_item.dart';

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


  static final Color modernGreen = Colors.green.shade700;
  static const double deleteIconSize = 30.0;


  Widget _buildScreenHeader(BuildContext context) {

    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Meu Carrinho',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          Icon(Icons.shopping_cart_checkout_rounded, size: 28, color: accentColor.withOpacity(0.7)),
        ],
      ),
    );
  }


  Widget _buildTotalSummaryItem(BuildContext context) {
    final Color accentColor = modernGreen;
    final Color lightBackground = modernGreen.withOpacity(0.08);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 25.0, bottom: 25.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: lightBackground,

          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment_outlined, color: accentColor, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Total do Pedido',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,

                      ),
                    ),
                  ],
                ),

                Text(
                  'R\$ ${cartTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    fontSize: 28,

                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButton(BuildContext context) {

    if (cartItems.isEmpty) return const SizedBox.shrink();

    return Container(

      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0), // Padding ajustado
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onConfirmOrder,
          icon: const Icon(Icons.receipt_long_rounded, size: 28),
          label: const Text('FINALIZAR E ENVIAR PEDIDO'),
          style: ElevatedButton.styleFrom(
            backgroundColor: modernGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {


    if (cartItems.isEmpty) {
      return Column(

        children: [
          _buildScreenHeader(context),
          const Divider(height: 0),
          Expanded(

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: Colors.grey.shade400
                  ),
                  const SizedBox(height: 16),
                  const Text(
                      'Seu carrinho está vazio! 🛒',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Adicione itens do cardápio para fazer o pedido.',
                      style: TextStyle(color: Colors.grey.shade600)
                  ),
                ],
              ),
            ),
          ),

        ],
      );
    }


    return Column(
      children: [
        _buildScreenHeader(context),
        const Divider(height: 0),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: cartItems.length + 1,
            itemBuilder: (context, index) {


              if (index == cartItems.length) {
                return _buildTotalSummaryItem(context);
              }


              final item = cartItems[index];
              return Card(

                elevation: 2,
                shadowColor: Colors.grey.shade500.withOpacity(0.3),
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(

                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),


                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary, fontSize: 16)),
                    ),
                  ),


                  title: Padding(

                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)), // Fonte maior
                  ),
                  subtitle: Text('R\$ ${(item.lineTotal / item.quantity).toStringAsFixed(2)} / un.', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),


                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Subtotal', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            Text(
                              'R\$ ${item.lineTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: modernGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: deleteIconSize),
                        onPressed: () => onRemoveItem(item.product.idProductItem),
                        tooltip: 'Remover Item',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        _buildActionButton(context),
      ],
    );
  }
}