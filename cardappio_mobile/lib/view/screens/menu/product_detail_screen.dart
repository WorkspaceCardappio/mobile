import 'package:flutter/material.dart';

import '../../../data/mock_data.dart';
import '../../../model/product.dart';
import '../../../model/product.dart'; // Mantenha apenas uma importação de product.dart

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

  // ESTADO PARA O STEPPER
  int _currentStep = 0;

  // VERIFICA SE O PASSO 1 (VARIÁVEL OBRIGATÓRIA) ESTÁ COMPLETO
  bool get _isStep1Complete => mockVariables.isEmpty || _selectedVariableValue != null;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.product.price;

    // Inicialização dos Adicionais
    for (var addon in mockAddOns) {
      _selectedAddOns[addon.id] = false;
    }

    // Inicialização da Variável (se houver)
    if (mockVariables.isNotEmpty && mockVariables.first.options.isNotEmpty) {
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

  // WIDGET DO PASSO 1: VARIÁVEIS OBRIGATÓRIAS
  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.product.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(widget.product.description, style: TextStyle(color: Colors.grey[700], fontSize: 16)),

        if (mockVariables.isNotEmpty) ...[
          const Divider(height: 30),
          Text(
              '1. Opções Variáveis (Obrigatório)',
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
        ] else const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text('Nenhuma opção variável obrigatória para este produto.'),
        ),
      ],
    );
  }

  // WIDGET DO PASSO 2: ADICIONAIS OPCIONAIS E QUANTIDADE
  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seção de Adicionais
        if (mockAddOns.isNotEmpty) ...[
          Text('2. Adicionais (Opcional)', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
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
          const Divider(height: 30),
        ] else const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text('Nenhum adicional disponível para este produto.'),
        ),

        // Seção de Quantidade
        Text('3. Quantidade', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
        const SizedBox(height: 15),
        Row(
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

            Text(
              'Total Item: R\$ ${(_currentPrice * _quantity).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Tamanho e Opções'),
        content: _buildStep1Content(),
        isActive: _currentStep == 0,
        state: _isStep1Complete ? StepState.complete : StepState.error,
      ),
      Step(
        title: const Text('Adicionais e Quantidade'),
        content: _buildStep2Content(),
        isActive: _currentStep == 1,
        state: StepState.editing,
      ),
    ];
  }

  // Lógica de avanço/conclusão do Stepper
  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_isStep1Complete) {
        setState(() => _currentStep = 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma opção variável antes de continuar.')),
        );
      }
    } else {
      _addOrderToCart();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context); // Se estiver no primeiro passo, apenas fecha a tela
    }
  }

  void _addOrderToCart() {
    Navigator.pop(context, {
      'quantity': _quantity,
      'total_item': (_currentPrice * _quantity),
      'addons': _selectedAddOns.entries.where((e) => e.value).map((e) => e.key).toList(),
      'variable': _selectedVariableValue,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 1,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: _buildSteps(),
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: details.onStepContinue,
                  icon: Icon(details.currentStep == _buildSteps().length - 1 ? Icons.add_shopping_cart : Icons.arrow_forward),
                  label: Text(details.currentStep == _buildSteps().length - 1 ? 'Adicionar ao Carrinho' : 'Continuar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(details.currentStep == 0 ? 'Cancelar' : 'Voltar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}