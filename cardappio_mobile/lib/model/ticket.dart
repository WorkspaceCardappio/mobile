import 'ticket_item.dart';

/// Representa uma comanda (ou ticket).
/// Usado tanto para a listagem/seleção simplificada quanto para a base de detalhes.
class Ticket {
  final String id;
  final int number; // ALTERADO: Renomeado de 'tableNumber' para 'number' para consistência com a API.
  final double total;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.number,
    required this.total,
    required this.createdAt,
  });

  /// Factory constructor para criar um Ticket a partir de um JSON.
  ///
  /// Este construtor é flexível e consegue lidar com duas fontes de dados:
  /// 1. A resposta do endpoint '/dto' (que tem 'id' e 'number' diretamente).
  /// 2. A resposta de um endpoint HATEOAS (que pode ter o 'id' dentro de '_links').
  factory Ticket.fromJson(Map<String, dynamic> json) {
    String id;

    // Tenta pegar o 'id' diretamente. Se não existir, tenta extrair do link HATEOAS.
    if (json.containsKey('id')) {
      id = json['id'] as String;
    } else {
      final String selfLink = json['_links']?['self']?['href'] ?? '';
      id = selfLink.isNotEmpty ? selfLink.substring(selfLink.lastIndexOf('/') + 1) : '';
    }

    // Pega o número da comanda, aceitando tanto 'number' (do DTO) quanto 'tableNumber' (do modelo antigo).
    final int ticketNumber = json['number'] ?? json['tableNumber'] ?? 0;

    final DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

    return Ticket(
      id: id,
      number: ticketNumber, // Mapeia para a propriedade 'number'
      total: (json['total'] as num? ?? 0.0).toDouble(),
      createdAt: createdAt,
    );
  }
}

/// Representa os detalhes completos de uma comanda, incluindo a lista de itens.
/// Herda as propriedades básicas da classe Ticket.
class TicketDetail extends Ticket {
  final List<TicketItem> items;

  TicketDetail({
    required super.id,
    required super.number,
    required super.total,
    required super.createdAt,
    required this.items,
  });

  /// Factory constructor para criar os detalhes da comanda a partir de um JSON.
  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    // Reutiliza a lógica do construtor pai para preencher os campos básicos.
    final baseTicket = Ticket.fromJson(json);

    final List<dynamic> itemsJson = json['_embedded']?['items'] ?? [];
    final List<TicketItem> items = itemsJson
        .map((itemJson) => TicketItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    // Opcional: Recalcula o total baseado nos itens para garantir consistência.
    double calculatedTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);

    return TicketDetail(
      id: baseTicket.id,
      number: baseTicket.number,
      total: (json['total'] as num? ?? calculatedTotal).toDouble(),
      createdAt: baseTicket.createdAt,
      items: items,
    );
  }
}