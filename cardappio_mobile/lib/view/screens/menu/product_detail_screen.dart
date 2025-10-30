import 'package:flutter/material.dart';
import '../../../data/api_service.dart';
import '../../../model/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ApiService apiService;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.apiService,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<ProductVariable> _productVariables = [];
  List<ProductAddOn> _productAddOns = [];

  // Variável para armazenar o Future
  late Future<void> _detailsFuture;

  int _quantity = 1;
  double _currentPrice = 0.0;
  String? _selectedVariableValue;
  final Map<String, int> _selectedAddOnQuantities = {};
  final TextEditingController _observationsController = TextEditingController();
  int _currentStep = 0;

  bool get _isStep1Complete =>
      _productVariables.isEmpty || _selectedVariableValue != null;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.product.price;
    // CRIA O FUTURE APENAS UMA VEZ AQUI
    _detailsFuture = _fetchProductDetails();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    final results = await Future.wait([
      widget.apiService.fetchProductVariables(widget.product.id),
      widget.apiService.fetchProductAddOns(widget.product.id),
    ]);

    final variables = results[0] as List<ProductVariable>;
    final addOns = results[1] as List<ProductAddOn>;

    if (mounted) {
      setState(() {
        _productVariables = variables;
        _productAddOns = addOns;

        for (var addon in _productAddOns) {
          _selectedAddOnQuantities[addon.id] = 0;
        }

        if (_productVariables.isNotEmpty &&
            _productVariables.first.options.isNotEmpty) {
          _selectedVariableValue = _productVariables.first.options.first.id;
        }

        _updateTotal();
      });
    }
  }

  void _updateTotal() {
    double basePrice = widget.product.price;

    if (_selectedVariableValue != null && _productVariables.isNotEmpty) {
      final selectedOption = _productVariables
          .expand((v) => v.options)
          .firstWhere(
            (opt) => opt.id == _selectedVariableValue,
        orElse: () =>
            ProductOption(id: '', name: '', priceAdjustment: 0.0),
      );
      basePrice += selectedOption.priceAdjustment;
    }

    for (var addon in _productAddOns) {
      final quantity = _selectedAddOnQuantities[addon.id] ?? 0;
      basePrice += addon.price * quantity;
    }

    setState(() {
      _currentPrice = basePrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 1,
      ),
      body: FutureBuilder<void>(
        // USA O FUTURE CRIADO EM initState
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Não foi possível carregar os detalhes do produto.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Stepper(
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
                        icon: Icon(
                          details.currentStep == _buildSteps().length - 1
                              ? Icons.add_shopping_cart
                              : Icons.arrow_forward,
                        ),
                        label: Text(
                          details.currentStep == _buildSteps().length - 1
                              ? 'Adicionar'
                              : 'Continuar',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: Text(
                          details.currentStep == 0 ? 'Cancelar' : 'Voltar',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ... (métodos _buildStep1Content, _buildStep2Content, _buildStep3Content, _buildSteps, _onStepContinue, _onStepCancel, _addOrderToCart permanecem inalterados)

  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
        ),
        if (_productVariables.isNotEmpty) ...[
          const Divider(height: 30),
          Text(
            '1. ${_productVariables.first.name} (Obrigatório)',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          ..._productVariables.first.options.map((option) {
            return RadioListTile<String>(
              title: Text(
                '${option.name} (${option.priceAdjustment >= 0 ? '+' : ''} R\$ ${option.priceAdjustment.toStringAsFixed(2)})',
              ),
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

  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_productAddOns.isNotEmpty) ...[
          Text(
            '2. Adicionais (Opcional)',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          ..._productAddOns.map((addon) {
            final quantity = _selectedAddOnQuantities[addon.id] ?? 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${addon.name} (+ R\$ ${addon.price.toStringAsFixed(2)})',
              ),
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
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3. Quantidade do Item',
          style:
          Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
        ),
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
              child: Text(
                '$_quantity',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 30),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => setState(() => _quantity++),
            ),
          ],
        ),
        const Divider(height: 40),
        Text(
          '4. Observações (Opcional)',
          style:
          Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
        ),
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

  List<Step> _buildSteps() {

    final List<Step> steps = [];

    int stepIndex = 0;

    if (_productVariables.isNotEmpty) {
      steps.add(
        Step(
          title: const Text('Opções'),
          content: _buildStep1Content(),
          isActive: _currentStep == stepIndex,
          state: _isStep1Complete ? StepState.complete : StepState.error,
        ),
      );
      stepIndex++;
    }

    if (_productAddOns.isNotEmpty) {
      steps.add(
        Step(
          title: const Text('Adicionais'),
          content: _buildStep2Content(),
          isActive: _currentStep == stepIndex,
        ),
      );
      stepIndex++;
    }

    steps.add(
      Step(
        title: const Text('Finalizar Item'),
        content: _buildStep3Content(),
        isActive: _currentStep == stepIndex,
      ),
    );

    return steps;
  }

  void _onStepContinue() {
    if (_currentStep == 0 && !_isStep1Complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma opção antes de continuar.'),
        ),
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

  void _addOrderToCart() {
    final Map<String, int> finalAddons = Map.from(_selectedAddOnQuantities)
      ..removeWhere((key, value) => value == 0);

    Navigator.pop(context, {
      'product_id': widget.product.id,
      'quantity': _quantity,
      'total_item': (_currentPrice * _quantity),
      'variable': _selectedVariableValue,
      'addons': finalAddons,
      'observations': _observationsController.text.trim(),
    });
  }
}