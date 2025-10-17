import 'ticket_item.dart';

class Ticket {
  final String id;
  final int tableNumber;
  final double total;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.tableNumber,
    required this.total,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final String selfLink = json['_links']['self']['href'];
    final String id = selfLink.substring(selfLink.lastIndexOf('/') + 1);
    final DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

    return Ticket(
      id: id,
      tableNumber: json['tableNumber'] ?? 0,
      total: (json['total'] ?? 0.0).toDouble(),
      createdAt: createdAt,
    );
  }
}

class TicketDetail extends Ticket {
  final List<TicketItem> items;

  TicketDetail({
    required super.id,
    required super.tableNumber,
    required super.total,
    required super.createdAt,
    required this.items,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    final String selfLink = json['_links']['self']['href'];
    final String id = selfLink.substring(selfLink.lastIndexOf('/') + 1);
    final DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

    final List<dynamic> itemsJson = json['_embedded']?['items'] ?? [];
    final List<TicketItem> items = itemsJson.map((itemJson) => TicketItem.fromJson(itemJson as Map<String, dynamic>)).toList();

    // Recalcula o total baseado nos itens mockados para garantir consistência
    double calculatedTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);

    return TicketDetail(
      id: id,
      tableNumber: json['tableNumber'] ?? 0,
      total: (json['total'] ?? calculatedTotal).toDouble(),
      createdAt: createdAt,
      items: items,
    );
  }
}