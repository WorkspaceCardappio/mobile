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
  final String? note; // <<< ADICIONADO: Campo opcional para notas
  final String image;  // <<< ADICIONADO: Campo para URL da imagem

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryName,
    this.note,
    required this.image, // <<< ADICIONADO ao construtor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      categoryName: json['categoryName'] as String?, // Mantido, se existir no JSON
      note: json['note'] as String?, // <<< LÊ o campo 'note'
      image: json['image'] as String? ?? '', // <<< LÊ o campo 'image' (string vazia se nulo)
    );
  }
}


class ProductAddOn {
  final String id;
  final String name;
  final double price;

  ProductAddOn({required this.id, required this.name, required this.price});

  factory ProductAddOn.fromJson(Map<String, dynamic> json) {
    return ProductAddOn(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}


class ProductOption {
  final String id;
  final String name;
  final double priceAdjustment;

  ProductOption({
    required this.id,
    required this.name,
    required this.priceAdjustment
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
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

  factory ProductVariable.fromJson(Map<String, dynamic> json) {
    var optionsListFromJson = json['options'] as List<dynamic>? ?? [];

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