import 'dart:convert';
import 'package:http/http.dart' as http;


import '../core/constants.dart';
import '../model/menu.dart';
import '../model/ticket.dart';

class ApiService {
  static Future<List<Menu>> fetchMenus() async {
    try {
      final response = await http.get(Uri.parse(kMenusEndpoint));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> menusJson = data['_embedded']?['menus'] ?? [];
        return menusJson.map((json) => Menu.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Falha ao carregar menus. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: Verifique se a API está rodando em $kBaseUrl.');
    }
  }

  static Future<List<Ticket>> fetchTickets() async {
    try {
      final response = await http.get(Uri.parse(kTicketsEndpoint));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> ticketsJson = data['_embedded']?['tickets'] ?? [];
        return ticketsJson.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Falha ao carregar comandas. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: Verifique se a API está rodando em $kBaseUrl. (${e.toString()})');
    }
  }

  static Future<TicketDetail> fetchTicketDetails(String ticketId) async {
    await Future.delayed(kApiMockDelay);

    final Map<String, dynamic> mockData = {
      'id': ticketId,
      'tableNumber': 5,
      'total': 0.0,
      'createdAt': DateTime.now().toIso8601String(),
      '_links': {'self': {'href': '$kBaseUrl/tickets/$ticketId'}},
      '_embedded': {
        'items': [
          {'productName': 'Picanha com Fritas', 'quantity': 1, 'unitPrice': 65.00},
          {'productName': 'Cerveja Artesanal IPA', 'quantity': 4, 'unitPrice': 15.00},
          {'productName': 'Batata Frita', 'quantity': 1, 'unitPrice': 12.90},
        ],
      },
    };

    return TicketDetail.fromJson(mockData);
  }

  static Future<bool> payTicket(String ticketId) async {
    await Future.delayed(const Duration(seconds: 1));
    return DateTime.now().millisecondsSinceEpoch % 10 < 9;
  }
}