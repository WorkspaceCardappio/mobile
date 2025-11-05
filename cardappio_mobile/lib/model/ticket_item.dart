class TicketItem {

  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;

  double get subtotal => unitPrice * quantity;

  TicketItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice
  });

  factory TicketItem.fromJson(Map<String, dynamic> json) {
    return TicketItem(

      id: json['id'] ?? 'mock_order_id_${json['productName']}',
      productName: json['productName'] ?? 'Item Desconhecido',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
    );
  }
}