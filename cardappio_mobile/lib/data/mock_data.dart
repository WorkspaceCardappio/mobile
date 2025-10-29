
import '../model/product.dart';

final List<ProductAddOn> mockAddOns = [
  ProductAddOn(id: 'a1', name: 'Bacon Extra', price: 5.00),
  ProductAddOn(id: 'a2', name: 'Molho Especial', price: 3.50),
  ProductAddOn(id: 'a3', name: 'Cebola Caramelizada', price: 4.00),
];

final List<ProductVariable> mockVariables = [
  ProductVariable(
    id: 'v1',
    name: 'Tamanho',
    options: [
      ProductOption(id: 'op1', name: 'Pequeno (300ml)', priceAdjustment: -5.00),
      ProductOption(id: 'op2', name: 'Médio (500ml)', priceAdjustment: 0.00),
      ProductOption(id: 'op3', name: 'Grande (700ml)', priceAdjustment: 3.00),
    ],
  ),
];

