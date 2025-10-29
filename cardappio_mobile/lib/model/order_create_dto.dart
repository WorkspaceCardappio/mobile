// Em lib/model/order_create_dto.dart

// -------- NOVAS CLASSES DE SUPORTE --------
// Representa um objeto que só tem um ID, como {"id": "..."}
class IdDTO {
  final String id;
  IdDTO({required this.id});
  Map<String, dynamic> toJson() => {'id': id};
}

// Representa um objeto de Enum, como {"code": "..."}
class EnumDTO {
  final String code;
  EnumDTO({required this.code});
  Map<String, dynamic> toJson() => {'code': code};
}
// ------------------------------------------


// -------- CLASSE PRINCIPAL ALTERADA --------
class OrderCreateDTO {
  // ANTES: final String ticketId;
  final IdDTO ticket; // AGORA: Um objeto IdDTO

  // ADICIONADO: O campo status que estava faltando
  final EnumDTO status;

  final List<OrderItemDTO> items;

  OrderCreateDTO({required this.ticket, required this.status, required this.items});

  Map<String, dynamic> toJson() {
    return {
      // ANTES: 'ticketId': ticketId,
      'ticket': ticket.toJson(), // AGORA: Converte o objeto ticket para JSON
      'status': status.toJson(), // ADICIONADO: Converte o objeto status para JSON
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

// Representa cada item dentro do pedido (esta classe não precisa de mudanças)
class OrderItemDTO {
  final String productId;
  final int quantity;
  final String? variableId;
  final String? observations;
  final List<OrderItemAdditionalDTO> additionals;

  OrderItemDTO({
    required this.productId,
    required this.quantity,
    this.variableId,
    this.observations,
    required this.additionals,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'variableId': variableId,
      'observations': observations,
      'additionals': additionals.map((add) => add.toJson()).toList(),
    };
  }
}

// Representa cada adicional dentro de um item (esta classe não precisa de mudanças)
class OrderItemAdditionalDTO {
  final String additionalId;
  final int quantity;

  OrderItemAdditionalDTO({required this.additionalId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'additionalId': additionalId,
      'quantity': quantity,
    };
  }
}