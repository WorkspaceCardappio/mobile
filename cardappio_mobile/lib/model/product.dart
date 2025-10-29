// Esta classe provavelmente veio dos seus dados mockados e pode não ser mais
// usada diretamente, já que agora temos a classe 'Category' (com id e name)
// vinda da API. Por enquanto, pode mantê-la.
class ProductCategory {
  final String name;
  final String icon;

  ProductCategory({required this.name, required this.icon});
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? categoryName; // ALTERADO: Tornou-se opcional (pode ser nulo)

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryName, // ALTERADO: Não é mais 'required'
  });

  // NOVO: Factory constructor para criar um Product a partir de um JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      // Garante que a descrição não seja nula, usando '' como padrão se não vier da API
      description: json['description'] as String? ?? '',
      // Converte o preço (que pode vir como int ou double) para double
      price: (json['price'] as num).toDouble(),
      // O categoryName não é preenchido aqui pois não vem nesta requisição da API
    );
  }
}

// As classes abaixo não precisam de alteração POR ENQUANTO.
// Elas provavelmente precisarão de um constructor 'fromJson' no futuro,
// quando você for buscar os detalhes de um único produto.
class ProductAddOn {
  final String id;
  final String name;
  final double price;

  ProductAddOn({required this.id, required this.name, required this.price});
}

class ProductOption {
  final String id;
  final String name;
  final double priceAdjustment;

  ProductOption({required this.id, required this.name, required this.priceAdjustment});
}

class ProductVariable {
  final String id;
  final String name;
  final List<ProductOption> options;

  ProductVariable({required this.id, required this.name, required this.options});
}