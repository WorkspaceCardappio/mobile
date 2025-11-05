class TicketItem {

  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;

  double get subtotal => unitPrice * quantity;

  TicketItem({
    this.id = 'N/A',
    required this.productName,
    required this.quantity,
    required this.unitPrice
  });

  factory TicketItem.fromJson(Map<String, dynamic> json) {
    return TicketItem(
      id: json['id'] as String? ?? 'mock_order_id',
      productName: json['productName'] as String? ?? 'Item Desconhecido',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num? ?? 0.0).toDouble(),
    );
  }

  factory TicketItem.fromBackendFlutterTicketJson(Map<String, dynamic> json) {
    return TicketItem(
      id: 'N/A',
      productName: json['name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['price'] as num).toDouble(),
    );
  }
}