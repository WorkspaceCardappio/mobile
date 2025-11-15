import 'package:flutter/foundation.dart';

@immutable
class ProductOrder {
  final String id;
  final String name;
  final double price;
  final int quantity;

  ProductOrder({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ProductOrder.fromJson(Map<String, dynamic> json) {
    return ProductOrder(
      id: json['id'] as String? ?? 'order_id_unknown',
      name: json['name'] as String? ?? 'Item Desconhecido',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      quantity: (json['quantity'] as num? ?? 0).toInt(),
    );
  }

  double get total => price * quantity;
}

class AggregatedOrder {
  final String orderId;
  final List<ProductOrder> items;

  AggregatedOrder({
    required this.orderId,
    required this.items,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  String get summary {
    return items.map((item) => '${item.quantity}x ${item.name}').join(', ');
  }
}


class Ticket {
  final String id;
  final int number;
  // 💡 MUDANÇA: 'total' foi renomeado para 'calculatedTotal'
  final double calculatedTotal;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.number,
    required this.calculatedTotal, // Renomeado
    required this.createdAt,
  });

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
      // 💡 Mapeia o campo 'total' da API para 'calculatedTotal'
      calculatedTotal: (json['total'] as num? ?? 0.0).toDouble(),
      createdAt: createdAt,
    );
  }
}


class TicketDetail extends Ticket {
  final List<AggregatedOrder> orders;

  TicketDetail({
    required super.id,
    required super.number,
    required super.createdAt,
    required this.orders,
  }) : super(
    // 💡 Usa a soma dos subtotais para o valor 'calculatedTotal' do super
    calculatedTotal: orders.fold(0.0, (sum, order) => sum + order.subtotal),
  );

  @override
  double get calculatedTotal {
    // 💡 O getter é mantido, mas é redundante e deve ser o único nome usado
    return orders.fold(0.0, (sum, order) => sum + order.subtotal);
  }

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    // ⚠️ ATENÇÃO: Se usar TicketDetail.fromJson, ele herdará o calculatedTotal
    // do Ticket.fromJson, que pode estar incorreto para um TicketDetail.
    // Recomenda-se usar apenas TicketDetail.fromBackendFlutterTicketJson
    // ou garantir que TicketDetail.fromJson calcule o total corretamente.

    final baseTicket = Ticket.fromJson(json);

    return TicketDetail(
      id: baseTicket.id,
      number: baseTicket.number,
      createdAt: baseTicket.createdAt,
      orders: [], // Dados de orders perdidos aqui, use o método fromBackendFlutterTicketJson
    );
  }

  factory TicketDetail.fromBackendFlutterTicketJson({
    required Map<String, dynamic> json,
    required Ticket baseTicket,
  }) {
    final List<dynamic> ordersJson = json['orders'] ?? [];
    final List<ProductOrder> allItems =
    ordersJson.map((item) => ProductOrder.fromJson(item)).toList();

    final Map<String, List<ProductOrder>> groupedByOrderId = {};
    for (var item in allItems) {
      final key = item.id;
      if (!groupedByOrderId.containsKey(key)) {
        groupedByOrderId[key] = [];
      }
      groupedByOrderId[key]!.add(item);
    }

    final List<AggregatedOrder> aggregatedOrders = groupedByOrderId.entries
        .map((entry) => AggregatedOrder(
      orderId: entry.key,
      items: entry.value,
    ))
        .toList();

    return TicketDetail(
      id: baseTicket.id,
      number: baseTicket.number,
      createdAt: baseTicket.createdAt,
      orders: aggregatedOrders,
    );
  }
}