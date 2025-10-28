import 'package:flutter/material.dart';

// Mantenha suas importações de mock_data e models aqui
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
  String? _selectedVariableValue;

  // 1. MUDANÇA NO ESTADO: Agora armazena a quantidade (int) de cada adicional.
  final Map<String, int> _selectedAddOnQuantities = {};

  // 2. NOVO ESTADO: Controller para o campo de texto das observações.
  final TextEditingController _observationsController = TextEditingController();

  int _currentStep = 0;

  bool get _isStep1Complete => mockVariables.isEmpty || _selectedVariableValue != null;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.product.price;

    // Inicializa o mapa de quantidades de adicionais com 0.
    for (var addon in mockAddOns) {
      _selectedAddOnQuantities[addon.id] = 0;
    }

    // Inicialização da Variável (se houver)
    if (mockVariables.isNotEmpty && mockVariables.first.options.isNotEmpty) {
      _selectedVariableValue = mockVariables.first.options.first.id;
    }

    _updateTotal(); // Calcula o preço inicial
  }

  // 3. NOVO MÉTODO: Lembre-se de fazer o dispose do controller.
  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  // 4. MUDANÇA NA LÓGICA: Atualiza o total considerando a quantidade de cada adicional.
  void _updateTotal() {
    double basePrice = widget.product.price;

    // Adiciona o ajuste de preço da variável obrigatória
    if (_selectedVariableValue != null) {
      final selectedOption = mockVariables
          .expand((v) => v.options)
          .firstWhere((opt) => opt.id == _selectedVariableValue,
          orElse: () =>
              ProductOption(id: '', name: '', priceAdjustment: 0.0));
      basePrice += selectedOption.priceAdjustment;
    }

    // Adiciona o preço dos adicionais (preço * quantidade)
    for (var addon in mockAddOns) {
      final quantity = _selectedAddOnQuantities[addon.id] ?? 0;
      basePrice += addon.price * quantity;
    }

    setState(() {
      _currentPrice = basePrice;
    });
  }

  // PASSO 1: Sem alterações
  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.product.name,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(widget.product.description,
            style: TextStyle(color: Colors.grey[700], fontSize: 16)),
        if (mockVariables.isNotEmpty) ...[
          const Divider(height: 30),
          Text('1. Opções (Obrigatório)',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
          const SizedBox(height: 10),
          ...mockVariables.first.options.map((option) {
            return RadioListTile<String>(
              title: Text(
                  '${option.name} (${option.priceAdjustment >= 0 ? '+' : ''} R\$ ${option.priceAdjustment.toStringAsFixed(2)})'),
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
        ]
      ],
    );
  }

  // 5. MUDANÇA NA UI: Interface de adicionais e quantidade.
  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mockAddOns.isNotEmpty) ...[
          Text('2. Adicionais (Opcional)',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
          const SizedBox(height: 10),
          // Mapeia os adicionais para uma lista de ListTile com controles de quantidade
          ...mockAddOns.map((addon) {
            final quantity = _selectedAddOnQuantities[addon.id] ?? 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${addon.name} (+ R\$ ${addon.price.toStringAsFixed(2)})'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: quantity > 0
                        ? () {
                      setState(() {
                        _selectedAddOnQuantities[addon.id] = quantity - 1;
                        _updateTotal();
                      });
                    }
                        : null,
                  ),
                  Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      setState(() {
                        _selectedAddOnQuantities[addon.id] = quantity + 1;
                        _updateTotal();
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ]
      ],
    );
  }

  // 6. NOVO WIDGET: Interface para as observações e quantidade do item principal.
  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seção de Quantidade do Item Principal
        Text('3. Quantidade do Item', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        const Divider(height: 40),

        // Seção de Observações
        Text('4. Observações (Opcional)', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
        const SizedBox(height: 15),
        TextFormField(
          controller: _observationsController,
          decoration: const InputDecoration(
            hintText: 'Ex: tirar a cebola, ponto da carne, etc.',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Display do preço total final
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Total do Pedido: R\$ ${(_currentPrice * _quantity).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // 7. MUDANÇA NO STEPPER: Adiciona o terceiro passo.
  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Opções'),
        content: _buildStep1Content(),
        isActive: _currentStep == 0,
        state: _isStep1Complete ? StepState.complete : StepState.error,
      ),
      Step(
        title: const Text('Adicionais'),
        content: _buildStep2Content(),
        isActive: _currentStep == 1,
      ),
      Step(
        title: const Text('Finalizar Item'),
        content: _buildStep3Content(),
        isActive: _currentStep == 2,
      ),
    ];
  }

  // 8. MUDANÇA NA LÓGICA: Ajusta a navegação para 3 passos.
  void _onStepContinue() {
    if (_currentStep == 0 && !_isStep1Complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma opção antes de continuar.')),
      );
      return;
    }

    if (_currentStep < _buildSteps().length - 1) {
      setState(() => _currentStep += 1);
    } else {
      _addOrderToCart();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  // 9. MUDANÇA NO RETORNO: Envia os novos dados para o carrinho.
  void _addOrderToCart() {
    // Filtra apenas os adicionais com quantidade > 0
    final Map<String, int> finalAddons = Map.from(_selectedAddOnQuantities)
      ..removeWhere((key, value) => value == 0);

    Navigator.pop(context, {
      'product_id': widget.product.id,
      'quantity': _quantity,
      'total_item': (_currentPrice * _quantity),
      'variable': _selectedVariableValue,
      'addons': finalAddons, // Envia o mapa de IDs e quantidades
      'observations': _observationsController.text.trim(), // Envia as observações
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 1,
      ),
      // Usar um SingleChildScrollView para evitar overflow em telas menores
      body: SingleChildScrollView(
        child: Stepper(
          // physics: ClampingScrollPhysics() ajuda o scroll do Stepper
          physics: const ClampingScrollPhysics(),
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
                    icon: Icon(details.currentStep == _buildSteps().length - 1
                        ? Icons.add_shopping_cart
                        : Icons.arrow_forward),
                    label: Text(details.currentStep == _buildSteps().length - 1
                        ? 'Adicionar'
                        : 'Continuar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      ),
    );
  }
}