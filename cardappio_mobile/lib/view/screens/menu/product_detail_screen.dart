import 'package:flutter/material.dart';

import '../../../data/mock_data.dart';
import '../../../model/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  double _currentPrice = 0.0;
  final Map<String, bool> _selectedAddOns = {};
  String? _selectedVariableValue;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.product.price;
    for (var addon in mockAddOns) {
      _selectedAddOns[addon.id] = false;
    }
    if (mockVariables.isNotEmpty) {
      _selectedVariableValue = mockVariables.first.options.first.id;
      _currentPrice += mockVariables.first.options.first.priceAdjustment;
    }
    _updateTotal();
  }

  void _updateTotal() {
    double basePrice = widget.product.price;

    if (_selectedVariableValue != null) {
      final selectedOption = mockVariables.expand((v) => v.options).firstWhere(
            (opt) => opt.id == _selectedVariableValue,
        orElse: () => ProductOption(id: '', name: '', priceAdjustment: 0.0),
      );
      basePrice += selectedOption.priceAdjustment;
    }

    for (var addon in mockAddOns) {
      if (_selectedAddOns[addon.id] == true) {
        basePrice += addon.price;
      }
    }

    setState(() {
      _currentPrice = basePrice;
    });
  }

  Widget _buildAddOnsSection() {
    if (mockAddOns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        Text('Adicionais (Opcional)', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
        const SizedBox(height: 10),
        ...mockAddOns.map((addon) {
          return CheckboxListTile(
            title: Text('${addon.name} (+ R\$ ${addon.price.toStringAsFixed(2)})'),
            value: _selectedAddOns[addon.id],
            onChanged: (bool? newValue) {
              setState(() {
                _selectedAddOns[addon.id] = newValue!;
                _updateTotal();
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildVariablesSection() {
    if (mockVariables.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        Text(
            'Opções Variáveis: Tamanho/Sabor (Obrigatório)',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)
        ),
        const SizedBox(height: 10),
        ...mockVariables.first.options.map((option) {
          return RadioListTile<String>(
            title: Text('${option.name} (R\$ ${option.priceAdjustment >= 0 ? '+' : ''} ${option.priceAdjustment.toStringAsFixed(2)})'),
            value: option.id,
            groupValue: _selectedVariableValue,
            onChanged: (String? value) {
              setState(() {
                _selectedVariableValue = value;
                _updateTotal();
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(widget.product.description, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
            const SizedBox(height: 16),

            _buildVariablesSection(),

            _buildAddOnsSection(),

            const SizedBox(height: 50),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 30),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 30),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, {
                'quantity': _quantity,
                'total_item': (_currentPrice * _quantity),
                'addons': _selectedAddOns.entries.where((e) => e.value).map((e) => e.key).toList(),
                'variable': _selectedVariableValue,
              });
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: Text('Adicionar R\$ ${(_currentPrice * _quantity).toStringAsFixed(2)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}