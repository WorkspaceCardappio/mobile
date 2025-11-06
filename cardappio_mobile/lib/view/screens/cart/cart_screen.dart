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

  // ⭐️ Cor de destaque sóbria e tamanho do ícone de exclusão
  static final Color modernGreen = Colors.green.shade700;
  static const double deleteIconSize = 30.0;

  // WIDGET: Cabeçalho da Tela (Para uniformidade)
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

  // ⭐️ WIDGET: Total como Item Final da Lista (Não Pinned)
  Widget _buildTotalSummaryItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 25.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total do Pedido:',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700, // Levemente mais forte
            ),
          ),
          // Valor Total em Verde Sóbrio e Destaque
          Text(
            'R\$ ${cartTotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w900,
              color: modernGreen,
              fontSize: 34, // Aumentado para destaque
            ),
          ),
        ],
      ),
    );
  }

  // ⭐️ WIDGET: Ação Final (Apenas o Botão, Sem Sombra no Contêiner)
  Widget _buildActionButton(BuildContext context) {
    return Container(
      // Removida a sombra e a decoração da parte inferior
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScreenHeader(context),
            const Divider(),
            Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Seu carrinho está vazio! 🛒', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Adicione itens do cardápio para fazer o pedido.', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildScreenHeader(context),
        const Divider(height: 0),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: cartItems.length + 1, // +1 para o item do Total
            itemBuilder: (context, index) {

              // ⭐️ Item de Resumo do Total (Fica no final da lista)
              if (index == cartItems.length) {
                return _buildTotalSummaryItem(context);
              }

              // ⭐️ Itens do Carrinho (Maiores)
              final item = cartItems[index];
              return Card(
                // Sombra Mínima entre os itens
                elevation: 1,
                shadowColor: Colors.black.withOpacity(0.08),
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  // Aumenta o padding vertical para item maior
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),

                  // Quantidade/Ícone
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

                  // Nome do Produto e Preço Unitário
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)), // Fonte maior
                  ),
                  subtitle: Text('R\$ ${(item.lineTotal / item.quantity).toStringAsFixed(2)} / un.', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),

                  // Total e Lixeira
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtotal
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

                      // Lixeira (Maior)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: deleteIconSize),
                        onPressed: () => onRemoveItem(item.product.id),
                        tooltip: 'Remover Item',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ⭐️ Botão de Ação Pinned (Sem total)
        _buildActionButton(context),
      ],
    );
  }
}