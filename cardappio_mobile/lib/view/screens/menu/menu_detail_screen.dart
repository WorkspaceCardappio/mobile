import 'package:flutter/material.dart';
import 'package:cardappio_mobile/model/menu.dart';
import 'package:cardappio_mobile/model/product.dart';
import '../../../data/api_service.dart';

class MenuDetailScreen extends StatelessWidget {
  final Menu menu;
  final String selectedCategoryName;
  final String selectedCategoryId;
  final Function(Product product) onProductTap;
  final ApiService apiService;


  const MenuDetailScreen({
    super.key,
    required this.menu,
    required this.selectedCategoryName,
    required this.selectedCategoryId,
    required this.onProductTap,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
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
            child: FutureBuilder<List<Product>>(
              future: apiService.fetchProductsByCategory(selectedCategoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Ocorreu um erro ao buscar os produtos.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum produto encontrado nesta categoria.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildProductCard(product, context),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
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
                child: Icon(
                  Icons.restaurant_menu,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
}