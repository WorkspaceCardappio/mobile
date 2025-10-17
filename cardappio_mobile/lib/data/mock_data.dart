
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

final List<ProductCategory> mockCategories = [
  ProductCategory(name: 'Destaques do Chef', icon: 'star'),
  ProductCategory(name: 'Pratos Principais', icon: 'dinner_dining'),
  ProductCategory(name: 'Lanches e Burgers', icon: 'lunch_dining'),
  ProductCategory(name: 'Porções e Petiscos', icon: 'tapas'),
  ProductCategory(name: 'Bebidas', icon: 'local_bar'),
  ProductCategory(name: 'Sobremesas', icon: 'cake'),
];

final List<Product> mockProducts = [
  Product(id: 'p1', name: 'Prato Executivo', description: 'O prato mais pedido, com arroz, feijão, bife e salada.', price: 39.90, categoryName: 'Destaques do Chef'),
  Product(id: 'p2', name: 'Mega Burger Duplo', description: 'Duas carnes, queijo, bacon e maionese especial.', price: 34.50, categoryName: 'Destaques do Chef'),
  Product(id: 'p3', name: 'Salmão Grelhado', description: 'Salmão fresco com legumes no vapor e azeite.', price: 55.00, categoryName: 'Pratos Principais'),
  Product(id: 'p4', name: 'Picanha com Fritas', description: 'Corte nobre de picanha, acompanha batata frita e vinagrete.', price: 65.00, categoryName: 'Pratos Principais'),
  Product(id: 'p5', name: 'Burger Clássico', description: 'Pão, carne, queijo e alface. Simples e saboroso.', price: 25.00, categoryName: 'Lanches e Burgers'),
  Product(id: 'p6', name: 'Sanduíche Vegano', description: 'Pão integral, hummus, pepino e rúcula.', price: 22.00, categoryName: 'Lanches e Burgers'),
  Product(id: 'p7', name: 'Batata Frita', description: 'Porção grande de batata frita com sal e pimenta.', price: 18.00, categoryName: 'Porções e Petiscos'),
  Product(id: 'p8', name: 'Aipim Frito', description: 'Porção de aipim frito sequinho, acompanha molho rosé.', price: 21.00, categoryName: 'Porções e Petiscos'),
  Product(id: 'p9', name: 'Cerveja Artesanal IPA', description: 'Lager encorpada e refrescante. 500ml.', price: 15.00, categoryName: 'Bebidas'),
  Product(id: 'p10', name: 'Suco de Laranja', description: 'Laranja espremida na hora. 300ml.', price: 10.00, categoryName: 'Bebidas'),
  Product(id: 'p11', name: 'Brownie com Sorvete', description: 'Brownie quente de chocolate com uma bola de sorvete de creme.', price: 18.00, categoryName: 'Sobremesas'),
  Product(id: 'p12', name: 'Mousse de Maracujá', description: 'Leve e refrescante mousse de maracujá caseira.', price: 14.00, categoryName: 'Sobremesas'),
];