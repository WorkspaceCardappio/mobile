// lib/model/product_order.dart (Sugestão: Crie este arquivo, ou renomeie o TicketItem)

// Renomeado para ProductOrder para representar o item de linha (produto)
// dentro do JSON de orders, antes de ser agregado.
class ProductOrder {
  // ID do item de linha, que no seu JSON é o ID do Pedido (Order ID)
  final String id;
  final String name; // Nome do produto
  final int quantity;
  final double price; // Preço unitário

  double get total => price * quantity;

  ProductOrder({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price
  });

  factory ProductOrder.fromJson(Map<String, dynamic> json) {
    return ProductOrder(
      id: json['id'] as String? ?? 'mock_order_id',
      name: json['name'] as String? ?? 'Item Desconhecido',
      // ⭐️ Conversão segura
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      // ⭐️ Conversão segura
      price: (json['price'] as num? ?? 0.0).toDouble(),
    );
  }
}