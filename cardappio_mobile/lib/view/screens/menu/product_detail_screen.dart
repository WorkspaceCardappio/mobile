import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    _detailsFuture = _fetchProductDetails();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    final results = await Future.wait([
      widget.apiService.fetchProductVariables(widget.product.idProduct),
      widget.apiService.fetchProductAddOns(widget.product.idProduct),
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
        orElse: () => ProductOption(id: '', name: '', priceAdjustment: 0.0),
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando detalhes...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao Carregar',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().split(':').last.trim(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // ⭐️ HEADER COM IMAGEM DO PRODUTO
              _buildProductHeader(),

              // ⭐️ STEPPER MODERNIZADO
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: colorScheme.copyWith(
                      primary: colorScheme.primary,
                    ),
                  ),
                  child: Stepper(
                    physics: const ClampingScrollPhysics(),
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    onStepContinue: _onStepContinue,
                    onStepCancel: _onStepCancel,
                    steps: _buildSteps(),
                    controlsBuilder: (context, details) {
                      final isLastStep = details.currentStep == _buildSteps().length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: details.onStepContinue,
                                icon: Icon(
                                  isLastStep ? Icons.shopping_cart : Icons.arrow_forward,
                                ),
                                label: Text(
                                  isLastStep ? 'Adicionar ao Carrinho' : 'Continuar',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLastStep
                                      ? Colors.green.shade600
                                      : colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: details.onStepCancel,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                details.currentStep == 0 ? 'Cancelar' : 'Voltar',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ⭐️ HEADER COM IMAGEM E INFO BÁSICA
  Widget _buildProductHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagem do produto
          Hero(
            tag: 'product-${widget.product.id}',
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade100,
                    Colors.white,
                  ],
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.product.image,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Imagem não disponível',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Info básica
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'R\$ ${widget.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐️ STEP 1: OPÇÕES (VARIÁVEIS)
  Widget _buildStep1Content() {
    if (_productVariables.isEmpty) return const SizedBox.shrink();

    final variable = _productVariables.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.tune,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                variable.name,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                'OBRIGATÓRIO',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...variable.options.map((option) {
          final isSelected = _selectedVariableValue == option.id;
          final hasAdjustment = option.priceAdjustment != 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: RadioListTile<String>(
              title: Text(
                option.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: hasAdjustment
                  ? Text(
                '${option.priceAdjustment >= 0 ? '+' : ''} R\$ ${option.priceAdjustment.toStringAsFixed(2)}',
                style: TextStyle(
                  color: option.priceAdjustment >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )
                  : null,
              value: option.id,
              groupValue: _selectedVariableValue,
              onChanged: (String? value) {
                setState(() {
                  _selectedVariableValue = value;
                  _updateTotal();
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          );
        }).toList(),
      ],
    );
  }

  // ⭐️ STEP 2: ADICIONAIS
  Widget _buildStep2Content() {
    if (_productAddOns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: Colors.orange.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Adicionais',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'OPCIONAL',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._productAddOns.map((addon) {
          final quantity = _selectedAddOnQuantities[addon.id] ?? 0;
          final isSelected = quantity > 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.orange.shade300 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+ R\$ ${addon.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Theme.of(context).colorScheme.primary,
                        iconSize: 28,
                        onPressed: quantity > 0
                            ? () {
                          setState(() {
                            _selectedAddOnQuantities[addon.id] = quantity - 1;
                            _updateTotal();
                          });
                        }
                            : null,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        alignment: Alignment.center,
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: Theme.of(context).colorScheme.primary,
                        iconSize: 28,
                        onPressed: () {
                          setState(() {
                            _selectedAddOnQuantities[addon.id] = quantity + 1;
                            _updateTotal();
                          });
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // ⭐️ STEP 3: FINALIZAR
  Widget _buildStep3Content() {
    final modernGreen = Colors.green.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantidade
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shopping_basket,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quantidade',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 32,
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 32,
                  onPressed: () => setState(() => _quantity++),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Observações
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_note,
                color: Colors.amber.shade800,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Observações',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Opcional)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _observationsController,
          decoration: InputDecoration(
            hintText: 'Ex: tirar a cebola, ponto da carne bem passado, etc.',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          maxLength: 200,
        ),

        const SizedBox(height: 24),

        // Total
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: modernGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: modernGreen.withOpacity(0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total do Item',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${(_currentPrice * _quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: modernGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: modernGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: modernGreen,
                  size: 32,
                ),
              ),
            ],
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
          subtitle: const Text('Escolha uma opção'),
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
          subtitle: const Text('Customize seu pedido'),
          content: _buildStep2Content(),
          isActive: _currentStep == stepIndex,
          state: _currentStep > stepIndex ? StepState.complete : StepState.indexed,
        ),
      );
      stepIndex++;
    }

    steps.add(
      Step(
        title: const Text('Finalizar'),
        subtitle: const Text('Confirme a quantidade'),
        content: _buildStep3Content(),
        isActive: _currentStep == stepIndex,
        state: StepState.indexed,
      ),
    );

    return steps;
  }

  void _onStepContinue() {
    if (_currentStep == 0 && !_isStep1Complete) {
      _showSnackBar('Por favor, selecione uma opção antes de continuar.', isError: true);
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
      'product_id': widget.product.idProductItem,
      'quantity': _quantity,
      'total_item': (_currentPrice * _quantity),
      'variable': _selectedVariableValue,
      'addons': finalAddons,
      'observations': _observationsController.text.trim(),
    });
  }
}