
class ProductOrder {

  final String id;
  final String name;
  final int quantity;
  final double price;

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

      quantity: (json['quantity'] as num? ?? 0).toInt(),

      price: (json['price'] as num? ?? 0.0).toDouble(),

    );
  }
}