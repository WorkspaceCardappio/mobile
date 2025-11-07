import 'ticket_item.dart';

class Ticket {
  final String id;
  final int number;
  final double total;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.number,
    required this.total,
    required this.createdAt,
  });

  // 🛠️ CORREÇÃO DE BUG DO DROPDOWN: Sobrescrevendo == e hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ticket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Ticket.fromJson(Map<String, dynamic> json) {
    String id;

    if (json.containsKey('id')) {
      id = json['id'] as String;
    } else {
      final String selfLink = json['_links']?['self']?['href'] ?? '';
      id = selfLink.isNotEmpty ? selfLink.substring(selfLink.lastIndexOf('/') + 1) : '';
    }

    final int ticketNumber = json['number'] ?? json['tableNumber'] ?? 0;

    final DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

    return Ticket(
      id: id,
      number: ticketNumber,
      total: (json['total'] as num? ?? 0.0).toDouble(),
      createdAt: createdAt,
    );
  }
}

class TicketDetail extends Ticket {
  final List<TicketItem> items;

  TicketDetail({
    required super.id,
    required super.number,
    required super.total,
    required super.createdAt,
    required this.items,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    final baseTicket = Ticket.fromJson(json);

    final List<dynamic> itemsJson = json['_embedded']?['items'] ?? [];
    final List<TicketItem> items = itemsJson
        .map((itemJson) => TicketItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    double calculatedTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);

    return TicketDetail(
      id: baseTicket.id,
      number: baseTicket.number,
      total: (json['total'] as num? ?? calculatedTotal).toDouble(),
      createdAt: baseTicket.createdAt,
      items: items,
    );
  }

  factory TicketDetail.fromBackendFlutterTicketJson({
    required Map<String, dynamic> json,
    required Ticket baseTicket,
  }) {
    final List<dynamic> ordersJson = json['orders'] ?? [];

    final List<TicketItem> items = ordersJson
        .map((itemJson) =>
        TicketItem.fromBackendFlutterTicketJson(itemJson as Map<String, dynamic>))
        .toList();

    // ⭐️ CORREÇÃO CRÍTICA: Calcula o total a partir dos itens (pedidos) carregados,
    // pois o campo 'total' não está mais vindo do JSON da API.
    final double calculatedTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);

    // ❌ REMOVIDO: final double total = (json['total'] as num).toDouble();
    // Essa linha causava o erro Null != num.

    return TicketDetail(
      id: baseTicket.id,
      number: baseTicket.number,
      createdAt: baseTicket.createdAt,
      total: calculatedTotal, // ⭐️ Usa o total calculado
      items: items,
    );
  }

  // O getter permanece, mas o total é definido no construtor com o valor calculado.
  double get calculatedTotal {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }
}