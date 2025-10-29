// NOVOS IMPORTS

import 'package:flutter/material.dart';
import 'package:cardappio_mobile/model/menu.dart';
import 'package:cardappio_mobile/model/product.dart';

import '../../../data/api_service.dart';

// REMOVIDO: import 'package:cardappio_mobile/data/mock_data.dart';

// ALTERADO: Convertido para StatefulWidget para gerenciar o estado da busca de produtos
class MenuDetailScreen extends StatefulWidget {
  final Menu menu;
  final String selectedCategoryName;
  final String selectedCategoryId; // NOVO: ID é crucial para a chamada da API
  final Function(Product product) onProductTap;

  const MenuDetailScreen({
    super.key,
    required this.menu,
    required this.selectedCategoryName,
    required this.selectedCategoryId, // Parâmetro agora é obrigatório
    required this.onProductTap,
  });

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  // NOVO: Variável de estado para armazenar o resultado da chamada da API
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a primeira busca por produtos quando a tela é construída
    _productsFuture = _fetchProducts();
  }

  // NOVO: Método de ciclo de vida que é chamado quando os parâmetros do widget mudam
  // (ex: quando o usuário clica em outra categoria)
  @override
  void didUpdateWidget(covariant MenuDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compara o ID da categoria antiga com a nova. Se mudou, busca os produtos novamente.
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId) {
      setState(() {
        _productsFuture = _fetchProducts();
      });
    }
  }

  // NOVO: Função auxiliar que efetivamente chama o serviço da API
  Future<List<Product>> _fetchProducts() {
    return ApiService.fetchProductsByCategory(widget.selectedCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    // A estrutura externa (cabeçalho da categoria) permanece
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.selectedCategoryName, // Usa o nome da categoria vindo do widget
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Divider(height: 20, thickness: 1),

          // ALTERADO: A área de produtos agora usa um FutureBuilder
          // para reagir ao estado da chamada da API (carregando, erro, sucesso)
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                // 1. Estado de Carregamento
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Estado de Erro
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Ocorreu um erro ao buscar os produtos.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                // 3. Sucesso, mas a lista está vazia
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum produto encontrado nesta categoria.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                  );
                }

                // 4. Sucesso com dados
                final products = snapshot.data!;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      // O card do produto é o mesmo, só que agora recebe dados da API
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

  // Este método não precisa de alterações, pois ele apenas exibe um produto
  Widget _buildProductCard(Product product, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => widget.onProductTap(product),
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
}