class TicketItem {

  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;

  double get subtotal => unitPrice * quantity;

  // ⭐️ CORREÇÃO 1: Remover o fallback 'N/A' e tornar o ID obrigatório no construtor
  TicketItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice
  });

  factory TicketItem.fromJson(Map<String, dynamic> json) {
    // Mantém fallback para IDs mock ou ausentes em APIs mais antigas
    return TicketItem(
      id: json['id'] as String? ?? 'mock_order_id',
      productName: json['productName'] as String? ?? 'Item Desconhecido',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num? ?? 0.0).toDouble(),
    );
  }

  factory TicketItem.fromBackendFlutterTicketJson(Map<String, dynamic> json) {
    // 🚀 CORREÇÃO 2: Lê o UUID real do campo 'id' do JSON (que agora está presente)
    final String orderId = json['id'] as String;

    return TicketItem(
      id: orderId, // Usa o UUID real
      productName: json['name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['price'] as num).toDouble(),
    );
  }
}