import 'dart:convert';
import 'package:http/http.dart' as http;


import '../core/constants.dart';
import '../model/category.dart';
import '../model/menu.dart';
import '../model/order_create_dto.dart';
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

  static Future<List<ProductAddOn>> fetchProductAddOns(String productId) async {
    final String endpoint = '$kAdditionalsEndpoint/$productId/flutter-additionals';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> addOnsJson = json.decode(utf8.decode(response.bodyBytes));
        return addOnsJson
            .map((json) => ProductAddOn.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Falha ao carregar adicionais do produto.');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao buscar adicionais: $e');
    }
  }

  static Future<List<Ticket>> fetchAvailableTickets() async {
    // Assumindo que seu endpoint de tickets DTO já existe
    final String endpoint = '$kTicketsEndpoint/dto';
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        // O backend retorna um objeto Page, pegamos o 'content'
        final List<dynamic> ticketsJson = data['content'] ?? [];
        return ticketsJson.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar comandas.');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao buscar comandas: $e');
    }
  }

  // NOVO: Cria um novo pedido
  static Future<void> createOrder(OrderCreateDTO order) async {
    // Assumindo que o endpoint de pedidos é /api/orders
    const String endpoint = '$kBaseUrl/api/orders';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(order.toJson()),
      );

      // 201 Created é a resposta de sucesso para POST
      if (response.statusCode != 201) {
        throw Exception('Falha ao criar o pedido. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao criar pedido: $e');
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

  static Future<List<ProductVariable>> fetchProductVariables(String productId) async {
    // Monta a URL final usando as constantes e o ID do produto
    final String endpoint = '$kProductVariablesEndpoint/$productId/flutter-product-variables';

    try {
      final response = await http.get(Uri.parse(endpoint));

      // Verifica se a requisição foi bem-sucedida
      if (response.statusCode == 200) {
        // Decodifica a resposta JSON (que é uma lista de objetos)
        final List<dynamic> optionsJson = json.decode(utf8.decode(response.bodyBytes));

        // Se a API não retornar nenhuma opção, retorna uma lista vazia.
        if (optionsJson.isEmpty) {
          return [];
        }

        // Converte cada objeto JSON da lista em um objeto ProductOption
        List<ProductOption> options = optionsJson
            .map((json) => ProductOption.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cria um único "ProductVariable" genérico para conter todas as opções recebidas.
        // Isso adapta o retorno da API para o que a UI do Flutter espera.
        final productVariable = ProductVariable(
          id: 'default-variable-id', // ID genérico, pois não vem da API
          name: 'Opções', // Nome genérico para o grupo de opções
          options: options,
        );

        // Retorna o ProductVariable dentro de uma lista, como a função exige.
        return [productVariable];

      } else {
        // Se o servidor respondeu com um erro, lança uma exceção
        throw Exception('Falha ao carregar as opções do produto. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Se ocorreu um erro de conexão ou outro problema, lança uma exceção
      throw Exception('Erro de conexão ao buscar as opções: $e');
    }
  }}