class ProductCategory {
  final String name;
  final String icon;

  ProductCategory({required this.name, required this.icon});
}

class Product {
  final String idProductItem;
  final String idProduct;
  final String name;
  final String description;
  final double price;
  final String? categoryName;
  final String? note;
  final String image;
  final String? imageUrl;

  Product({
    required this.idProductItem,
    required this.idProduct,
    required this.name,
    required this.description,
    required this.price,
    this.categoryName,
    this.note,
    required this.image,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProductItem: json['idProductItem'] as String,
      idProduct: json['idProduct'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),

      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',

      imageUrl: json['imageUrl'] as String?,

      categoryName: json['categoryName'] as String?,
      note: json['note'] as String?,
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