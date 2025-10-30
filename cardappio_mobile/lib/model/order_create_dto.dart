class IdDTO {
  final String id;

  IdDTO({required this.id});

  Map<String, dynamic> toJson() => {'id': id};
}

class EnumDTO {
  final String code;

  EnumDTO({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}

class OrderCreateDTO {
  final IdDTO ticket;
  final EnumDTO status;
  final List<OrderItemDTO> items;

  OrderCreateDTO({
    required this.ticket,
    required this.status,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'ticket': ticket.toJson(),
    'status': status.toJson(),
    'items': items.map((item) => item.toJson()).toList(),
  };
}

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

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'variableId': variableId,
    'observations': observations,
    'additionals': additionals.map((add) => add.toJson()).toList(),
  };
}

class OrderItemAdditionalDTO {
  final String additionalId;
  final int quantity;

  OrderItemAdditionalDTO({
    required this.additionalId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'additionalId': additionalId,
    'quantity': quantity,
  };
}