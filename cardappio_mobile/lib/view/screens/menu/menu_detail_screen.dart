// lib/presentation/screens/menu/menu_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cardappio_mobile/model/menu.dart'; // Importe conforme sua estrutura
import 'package:cardappio_mobile/model/product.dart'; // Importe conforme sua estrutura
import 'package:cardappio_mobile/data/mock_data.dart'; // Importe conforme sua estrutura

class MenuDetailScreen extends StatelessWidget {
  final Menu menu;
  // PARÂMETRO CORRIGIDO: Adicione 'selectedCategoryName' ao construtor
  final String selectedCategoryName;
  final Function(Product product) onProductTap;

  const MenuDetailScreen({
    super.key,
    required this.menu,
    required this.selectedCategoryName, // Torne-o um parâmetro obrigatório
    required this.onProductTap,
  });

  // ... (o método _buildProductCard permanece o mesmo)
  Widget _buildProductCard(Product product, BuildContext context) {
    // ... (implementação do Card)
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onProductTap(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant_menu, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductArea(BuildContext context) {
    // Filtra usando a categoria recebida via parâmetro
    final filteredProducts = mockProducts.where(
          (product) => product.categoryName == selectedCategoryName,
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedCategoryName,
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Divider(height: 20, thickness: 1),

          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
              child: Text(
                'Nenhum produto encontrado nesta categoria.',
                style: TextStyle(color: Colors.grey[600], fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildProductCard(product, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductArea(context);
  }
}