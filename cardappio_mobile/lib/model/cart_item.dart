import 'package:cardappio_mobile/model/product.dart';


/// Representa um item dentro do carrinho de compras.
///
/// Além do produto e da quantidade, agora armazena os detalhes da personalização
/// (variáveis, adicionais, observações) e o subtotal já calculado para esta linha.
class CartItem {
  final Product product;
  int quantity;

  // NOVO: Um mapa para guardar todos os detalhes de personalização do item.
  // Isso inclui a variável selecionada, os adicionais e as observações.
  final Map<String, dynamic> details;

  // NOVO: Armazena o subtotal já calculado para esta linha do carrinho.
  // Este valor vem da ProductDetailScreen e já inclui os custos de
  // variáveis e adicionais.
  final double lineTotal;

  CartItem({
    required this.product,
    required this.quantity,
    this.details = const {}, // Opcional, com um mapa vazio como valor padrão
    required this.lineTotal,
  });

// REMOVIDO: O getter 'subtotal' foi substituído pela propriedade 'lineTotal'.
// O cálculo antigo (product.price * quantity) era incorreto pois não
// considerava os custos dos adicionais e o ajuste de preço da variável.
// double get subtotal => product.price * quantity;
}