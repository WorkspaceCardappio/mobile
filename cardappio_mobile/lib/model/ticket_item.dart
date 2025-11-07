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
    // Este factory já está tratando nulos com 'as num? ?? 0' e 'as num? ?? 0.0'
    return TicketItem(
      id: json['id'] as String? ?? 'mock_order_id',
      productName: json['productName'] as String? ?? 'Item Desconhecido',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num? ?? 0.0).toDouble(),
    );
  }

  factory TicketItem.fromBackendFlutterTicketJson(Map<String, dynamic> json) {
    // A chave 'id' deve ser tratada como String, mas os numéricos precisam de cuidado.
    final String orderId = json['id'] as String? ?? ''; // Protegendo o ID de ser nulo também.

    // 🚀 CORREÇÃO CRÍTICA: Usar 'as num? ?? 0' para evitar a falha 'Null is not a subtype of num'.

    return TicketItem(
      id: orderId,
      productName: json['name'] as String? ?? 'Item Desconhecido',

      // ⭐️ CORREÇÃO 1: Quantity - Se for nulo, usa 0, depois converte para int.
      quantity: (json['quantity'] as num? ?? 0).toInt(),

      // ⭐️ CORREÇÃO 2: unitPrice - Se for nulo, usa 0.0, depois converte para double.
      unitPrice: (json['price'] as num? ?? 0.0).toDouble(),
    );
  }
}