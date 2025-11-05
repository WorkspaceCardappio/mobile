class SplitOrdersDTO {

  final Set<String> orders;


  final String? ticket;

  SplitOrdersDTO({required this.orders, this.ticket});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'orders': orders.toList(),
    };


    if (ticket != null) {
      data['ticket'] = ticket;
    }

    return data;
  }
}