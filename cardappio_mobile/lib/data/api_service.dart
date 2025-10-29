import 'dart:convert';
import 'package:http/http.dart' as http;


import '../core/constants.dart';
import '../model/category.dart';
import '../model/menu.dart';
import '../model/product.dart';
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

  static Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    // Se a categoria não tiver um ID, retorna uma lista vazia para evitar erros.
    if (categoryId.isEmpty) return [];

    final String endpoint = '$kProductsEndpoint/$categoryId/flutter-products';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(utf8.decode(response.bodyBytes));
        // Assumindo que seu modelo Product tem um factory constructor 'fromJson'
        return productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Falha ao carregar produtos. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao buscar produtos: $e');
    }
  }

  static Future<List<Category>> fetchCategories(String menuId) async {
    final String endpoint = '$kCategoriesEndpoint/d2e3f4a5-b1c6-7890-1234-567890abcdef/flutter-categories';    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = json.decode(utf8.decode(response.bodyBytes));
        return categoriesJson
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Falha ao carregar categorias. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao buscar categorias: $e');
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