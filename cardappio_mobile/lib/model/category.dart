class Category {
  final String id;
  final String name;
  final String image;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.image,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}