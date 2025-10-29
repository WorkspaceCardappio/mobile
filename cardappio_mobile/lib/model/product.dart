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
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
    );
  }
}

// ... (outras classes: Product, ProductCategory, etc.)

class ProductAddOn {
  final String id;
  final String name;
  final double price;

  ProductAddOn({required this.id, required this.name, required this.price});

  // NOVO: Adicione este factory constructor para ler o JSON da API
  factory ProductAddOn.fromJson(Map<String, dynamic> json) {
    return ProductAddOn(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}

// ... (outras classes: ProductOption, ProductVariable)

// =========================================================================
// CORREÇÃO PRINCIPAL AQUI
// =========================================================================

class ProductOption {
  final String id;
  final String name;
  final double priceAdjustment;

  ProductOption({
    required this.id,
    required this.name,
    required this.priceAdjustment
  });

  // NOVO: Adicione este factory constructor para corrigir o erro.
  factory ProductOption.fromJson(Map<String, dynamic> json) {
    // Note que estamos mapeando o campo 'price' que vem da API
    // para o nosso campo 'priceAdjustment' no modelo do Flutter.
    return ProductOption(
      id: json['id'] as String,
      name: json['name'] as String,
      priceAdjustment: (json['price'] as num? ?? 0.0).toDouble(),
    );
  }
}

class ProductVariable {
  final String id;
  final String name;
  final List<ProductOption> options;

  ProductVariable({required this.id, required this.name, required this.options});

  // NOVO: É uma boa prática adicionar o fromJson aqui também.
  factory ProductVariable.fromJson(Map<String, dynamic> json) {
    // Pega a lista de 'options' do JSON
    var optionsListFromJson = json['options'] as List<dynamic>? ?? [];

    // Converte a lista de JSON em uma lista de objetos ProductOption
    List<ProductOption> parsedOptions = optionsListFromJson
        .map((optionJson) => ProductOption.fromJson(optionJson as Map<String, dynamic>))
        .toList();

    return ProductVariable(
      id: json['id'] as String,
      name: json['name'] as String,
      options: parsedOptions,
    );
  }
}