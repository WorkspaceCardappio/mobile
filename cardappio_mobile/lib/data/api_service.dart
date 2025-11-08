import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../model/category.dart';
import '../model/menu.dart';
import '../model/order_create_dto.dart';
import '../model/product.dart';
import '../model/split_orders_dto.dart';
import '../model/ticket.dart';
import '../model/ticket_item.dart'; // Garantindo que todos os modelos sejam importados (se ticket_item foi renomeado, ajuste o caminho)

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> _get(String endpoint) async {
    try {
      final response = await _client.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha na requisição GET: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  Future<void> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(data),
      );
      if (response.statusCode != 201) {
        throw Exception('Falha ao criar o recurso: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  Future<void> _postVoid(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(data),
      );
      if (response.statusCode != 200) {
        throw Exception('Falha na requisição POST: Status ${response.statusCode}. Resposta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }


  Future<List<Menu>> fetchMenus() async {
    final data = await _get(kMenusEndpoint);
    final List<dynamic> menusJson = data['_embedded']?['menus'] ?? [];
    return menusJson.map((json) => Menu.fromJson(json)).toList();
  }

  Future<List<Ticket>> fetchTickets() async {
    final data = await _get(kTicketsEndpoint);
    final List<dynamic> ticketsJson = data['_embedded']?['tickets'] ?? [];
    return ticketsJson.map((json) => Ticket.fromJson(json)).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    if (categoryId.isEmpty) return [];
    final endpoint = '$kProductsEndpoint/$categoryId/flutter-products';
    final List<dynamic> productsJson = await _get(endpoint);
    // ✅ Este método deve estar correto se Product.fromJson estiver OK.
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Category>> fetchCategories(String menuId) async {
    final endpoint = '$kCategoriesEndpoint/$menuId/flutter-categories';
    final List<dynamic> categoriesJson = await _get(endpoint);
    // ✅ Este método deve estar correto.
    return categoriesJson.map((json) => Category.fromJson(json)).toList();
  }

  // ⭐️ MÉTODO CORRIGIDO: Adicionando verificação de Map para garantir tipagem
  Future<List<ProductAddOn>> fetchProductAddOns(String productId) async {
    final endpoint = '$kAdditionalsEndpoint/$productId/flutter-additionals';
    final List<dynamic> addOnsJson = await _get(endpoint);

    return addOnsJson
    // Garante que só Maps válidos sejam passados
        .where((json) => json is Map<String, dynamic>)
        .map((json) => ProductAddOn.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ticket>> fetchAvailableTickets() async {
    final endpoint = '$kTicketsEndpoint/dto';
    final data = await _get(endpoint);
    final List<dynamic> ticketsJson = data['content'] ?? [];
    return ticketsJson.map((json) => Ticket.fromJson(json)).toList();
  }

  Future<List<ProductVariable>> fetchProductVariables(String productId) async {
    final endpoint = '$kProductVariablesEndpoint/$productId/flutter-product-variables';
    final List<dynamic> optionsJson = await _get(endpoint);
    if (optionsJson.isEmpty) {
      return [];
    }
    List<ProductOption> options = optionsJson.map((json) => ProductOption.fromJson(json)).toList();
    final productVariable = ProductVariable(
      id: 'default-variable-id',
      name: 'Opções',
      options: options,
    );
    return [productVariable];
  }


  Future<void> createOrder(OrderCreateDTO order) async {
    const endpoint = '$kBaseUrl/api/orders/flutter-orders';
    await _post(endpoint, order.toJson());
  }

  Future<void> splitTicket(String ticketId, SplitOrdersDTO splitData) async {

    final endpoint = '$kBaseUrl/api/tickets/split/$ticketId';

    await _postVoid(endpoint, splitData.toJson());
  }

  Future<TicketDetail> fetchTicketDetails(Ticket baseTicket) async {
    final uri = Uri.parse('http://10.0.2.2:8080/api/tickets/flutter-tickets/by-ticket/${baseTicket.id}');

    print('DEBUG URL: $uri');

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        return TicketDetail.fromBackendFlutterTicketJson(
          json: jsonResponse,
          baseTicket: baseTicket,
        );
      } else if (response.statusCode == 404) {
        throw Exception('Comanda não encontrada: ID ${baseTicket.id}');
      } else {
        throw Exception('Falha ao carregar detalhes. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de rede: ${e.toString()}');
    }
  }

  Future<bool> payTicket(String ticketId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}