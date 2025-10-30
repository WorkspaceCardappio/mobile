import 'package:cardappio_mobile/model/product.dart';


class CartItem {
  final Product product;
  int quantity;


  final Map<String, dynamic> details;
  final double lineTotal;

  CartItem({
    required this.product,
    required this.quantity,
    this.details = const {},
    required this.lineTotal,
  });

}