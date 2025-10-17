class TicketItem {
  final String productName;
  final int quantity;
  final double unitPrice;

  double get subtotal => unitPrice * quantity;

  TicketItem({required this.productName, required this.quantity, required this.unitPrice});

  factory TicketItem.fromJson(Map<String, dynamic> json) {
    return TicketItem(
      productName: json['productName'] ?? 'Item Desconhecido',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
    );
  }
}