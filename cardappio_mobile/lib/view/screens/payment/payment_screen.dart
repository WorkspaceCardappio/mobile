import 'package:cardappio_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/api_service.dart';
import '../../../model/ticket.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../model/abacate_pix_responseDTO.dart';
import '../../../model/pix_form_data.dart'; 
import '../../../model/pix_payment_request_dto.dart';
import '../../../model/ticket_item.dart' hide ProductOrder;

class PaymentScreen extends StatefulWidget {
  final Ticket? preSelectedTicket;
  final ApiService apiService;

  const PaymentScreen({
    super.key,
    this.preSelectedTicket,
    required this.apiService,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Ticket? _selectedTicket;
  TicketDetail? _ticketDetail;
  Future<TicketDetail>? _ticketDetailFuture;

  int _currentStep = 0;
  String _paymentOption = 'total';
  final TextEditingController _partialController = TextEditingController();

  final PixFormData _pixFormData = PixFormData(
    customerName: '', customerEmail: '', customerTaxId: '', customerCellphone: '',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AbacatePixResponseDTO? _pixResponse;

  @override
  void initState() {
    super.initState();
    _selectedTicket = widget.preSelectedTicket;

    if (_selectedTicket != null) {
      _startFetchingDetails(_selectedTicket!);
    }
  }

  @override
  void dispose() {
    _partialController.dispose();
    super.dispose();
  }

  void _startFetchingDetails(Ticket ticket) {
    final future = widget.apiService.fetchTicketDetails(ticket);

    setState(() {
      _ticketDetailFuture = future.then((detail) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _ticketDetail = detail;
                _updatePartialAmount(detail.calculatedTotal);
              });
            }
          });
        }
        return detail;
      });
    });
  }

  void _updatePartialAmount(double total) {
    setState(() {
      _partialController.text = total.toStringAsFixed(2);
    });
  }

  void _handlePaymentProcessing() async {
    final double grandTotal = _ticketDetail?.calculatedTotal ?? 0.0;
  
  double amountToPay = (_paymentOption == 'total') 
      ? grandTotal 
      : double.tryParse(_partialController.text.replaceAll(',', '.')) ?? 0.0;
  
  if (_selectedTicket == null || amountToPay <= 0) {
    _showSnackBar('Selecione uma comanda e/ou valor válido.', isError: true);
    return;
  }
  
  if (!_formKey.currentState!.validate()) {
    _showSnackBar('Preencha todos os dados do pagador corretamente.', isError: true);
    return;
  }
  
  final pixRequest = PixPaymentRequestDTO(
    ticketId: _selectedTicket!.id.toString(), 
    description: 'Comanda #${_selectedTicket!.number}',
    amount: amountToPay,
    customerData: _pixFormData, 
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Gerando Pix...'),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    final response = await widget.apiService.createPixPayment(pixRequest);

    if (!mounted) return;
    Navigator.pop(context); 

    if (response != null && response.status == 'PENDING') {
      setState(() {
        _pixResponse = response;
        _currentStep = 3; 
      });
      _showSnackBar('Pix gerado com sucesso! Aguardando pagamento.', isSuccess: true);
    } else {
      _showSnackBar('Falha ao gerar Pix. Verifique a resposta da API.', isError: true);
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context); 
    _showSnackBar('Erro de comunicação: ${e.toString().split(':').last.trim()}', isError: true);
  }
  }

  void _handleSimulatePayment() async {
    if (_pixResponse == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await widget.apiService.simulatePixPayment(_pixResponse!.pixId);

      if (!mounted) return;
      Navigator.pop(context);

      _showSnackBar('Simulação de pagamento APROVADA! O Webhook atualizou a Comanda.', isSuccess: true);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              OrderApp.mainNavigatorRoute,
                  (Route<dynamic> route) => false,
          arguments: 2);
        }
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('Falha na Simulação: ${e.toString().split(':').last.trim()}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : (isError ? Icons.error : Icons.info),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess
            ? Colors.green.shade600
            : (isError ? Colors.red.shade600 : Colors.blue.shade600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextFormField({
  required String label,
  required String initialValue,
  required ValueChanged<String> onChanged,
  required FormFieldValidator<String> validator,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextFormField(
    initialValue: initialValue,
    onChanged: onChanged,
    validator: validator,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

Widget _buildCustomerData() {
  return Form(
    key: _formKey, 
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados do Pagador (Obrigatório para Pix)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        _buildTextFormField(
          label: 'Nome Completo',
          initialValue: _pixFormData.customerName,
          onChanged: (v) => _pixFormData.customerName = v.trim(),
          validator: (v) => (v?.isEmpty ?? true) ? 'O nome é obrigatório.' : null,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 12),

        _buildTextFormField(
          label: 'E-mail',
          initialValue: _pixFormData.customerEmail,
          onChanged: (v) => _pixFormData.customerEmail = v.trim(),
          validator: (v) {
            if (v?.isEmpty ?? true) {
              return 'O e-mail é obrigatório.';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v!)) {
              return 'E-mail inválido.';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),

        _buildTextFormField(
          label: 'CPF ou CNPJ (somente números)',
          initialValue: _pixFormData.customerTaxId,
          onChanged: (v) => _pixFormData.customerTaxId = v.replaceAll(RegExp(r'\D'), ''), 
          validator: (v) {
            final cleaned = v?.replaceAll(RegExp(r'\D'), '') ?? '';
            if (cleaned.isEmpty) {
              return 'O documento é obrigatório.';
            }
            if (cleaned.length != 11 && cleaned.length != 14) {
              return 'Documento inválido (11 ou 14 dígitos).';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),

        _buildTextFormField(
          label: 'Telefone (DDD + Número)',
          initialValue: _pixFormData.customerCellphone,
          onChanged: (v) => _pixFormData.customerCellphone = v.replaceAll(RegExp(r'\D'), ''), 
          validator: (v) {
            final cleaned = v?.replaceAll(RegExp(r'\D'), '') ?? '';
            if (cleaned.length < 10 || cleaned.length > 11) {
              return 'Telefone inválido (mínimo 10, máximo 11 dígitos).';
            }
            return null;
          },
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
        ),
        
        const SizedBox(height: 24),
      ],
    ),
  );
}

  Widget _buildStep4PixDisplay() {
    if (_pixResponse == null) {
      return const Center(child: Text('Gere o Pix para visualizá-lo.'));
    }

    String rawBase64 = _pixResponse!.brCodeBase64;
    if (rawBase64.startsWith('data:image/png;base64,')) {
      rawBase64 = rawBase64.substring('data:image/png;base64,'.length);
    }

    final qrCodeBytes = base64Decode(rawBase64);
    final String pixCode = _pixResponse!.brCode;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pague sua comanda via Pix',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use seu aplicativo bancário para escanear:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.memory(
                qrCodeBytes,
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return QrImageView(
                    data: pixCode,
                    version: QrVersions.auto,
                    size: 200.0,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Ou copie a chave Pix (Copia e Cola):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: pixCode));
                _showSnackBar('Código Pix Copia e Cola copiado!', isSuccess: true);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        pixCode,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy, size: 18, color: Colors.blue),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _handleSimulatePayment,
              icon: const Icon(Icons.bug_report, size: 24),
              label: const Text(
                'SIMULAR PAGAMENTO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
            ),

            const SizedBox(height: 32),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.watch_later_outlined, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Aguardando a confirmação do pagamento...',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketNumberBadge(int number, {double size = 50}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '#$number',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.32,
          ),
        ),
      ),
    );
  }

  Widget _buildStep1SelectTicket(List<Ticket> availableTickets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Ticket>(
              isExpanded: true,
              value: _selectedTicket,
              hint: const Text('Selecione uma comanda'),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: availableTickets.map((ticket) {
                return DropdownMenuItem(
                  value: ticket,
                  child: Row(
                    children: [
                      _buildTicketNumberBadge(ticket.number, size: 35),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Comanda ${ticket.number}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Ticket? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTicket = newValue;
                    _ticketDetail = null;
                    _paymentOption = 'total';
                    if (_currentStep == 1) {
                      _currentStep = 0;
                    }
                  });
                  _startFetchingDetails(newValue);
                }
              },
            ),
          ),
        ),

        _buildTicketDetailsLoader(),
      ],
    );
  }

  Widget _buildTicketDetailsLoader() {
    if (_ticketDetailFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<TicketDetail>(
      future: _ticketDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erro: ${snapshot.error.toString().split(':').last.trim()}',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData && _ticketDetail != null) {
          return _buildTicketDetailConfirmation(_ticketDetail!);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTicketDetailConfirmation(TicketDetail detail) {
    final double grandTotal = detail.calculatedTotal;
    final List<ProductOrder> allProducts =
    detail.orders.expand((order) => order.items).cast<ProductOrder>().toList();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildTicketNumberBadge(detail.number, size: 45),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Comanda ${detail.number}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Itens do Pedido',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...allProducts.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          'R\$ ${item.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Geral',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'R\$ ${grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2PaymentOptions() {
    if (_ticketDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final double grandTotal = _ticketDetail!.calculatedTotal;
    final modernGreen = Colors.green.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              _buildTicketNumberBadge(_ticketDetail!.number, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comanda ${_ticketDetail!.number}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${grandTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: modernGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Icon(Icons.payment_rounded, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Forma de Pagamento',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildPaymentOptionCard(
          title: 'Pagamento Total',
          subtitle: 'Pagar o valor completo da comanda',
          value: 'total',
          icon: Icons.credit_card,
          color: modernGreen,
        ),

        const SizedBox(height: 12),


        _buildPaymentOptionCard(
          title: 'Pagamento Parcial',
          subtitle: 'Pagar apenas uma parte do valor',
          value: 'partial',
          icon: Icons.account_balance_wallet,
          color: Colors.blue.shade600,
        ),


        if (_paymentOption == 'partial')
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Informe o valor a pagar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _partialController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    prefixText: 'R\$ ',
                    prefixStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    helperText: 'Máximo: R\$ ${grandTotal.toStringAsFixed(2)}',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentOptionCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _paymentOption == value;

    return InkWell(
      onTap: () => setState(() => _paymentOption = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? color : Colors.grey.shade600, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 28),
          ],
        ),
      ),
    );
  }

  List<Step> _buildSteps(List<Ticket> availableTickets) {
    return [
      Step(
        title: const Text('Selecionar Comanda'),
        subtitle: const Text('Escolha e confira os itens'),
        content: _buildStep1SelectTicket(availableTickets),
        isActive: _currentStep == 0,
        state: _selectedTicket != null && _ticketDetail != null
            ? StepState.complete
            : StepState.indexed,
      ),
      Step(
      title: const Text('Opções de Pagamento'),
      subtitle: const Text('Escolha a forma de pagamento'),
      content: _buildStep2PaymentOptions(),
      isActive: _currentStep == 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Dados do Pagador'),
      subtitle: const Text('Informações para o Pix'),
      content: _buildCustomerData(),
      isActive: _currentStep == 2,
      state: _currentStep > 2 || (_currentStep == 2 && _formKey.currentState?.validate() == true)
          ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Pagar com Pix'),
      subtitle: const Text('Escanear ou Copiar'),
      content: _buildStep4PixDisplay(),
      isActive: _currentStep == 3,
      state: _pixResponse != null ? StepState.complete : StepState.indexed,
    ),
  ];
}
     
  void _onStepContinue() async {
    if (_currentStep == 0) {
    if (_selectedTicket != null && _ticketDetail != null) {
      setState(() => _currentStep = 1);
    } else {
      _showSnackBar('Selecione e carregue a comanda.', isError: true);
    }
  } else if (_currentStep == 1) {
    setState(() => _currentStep = 2);
  } else if (_currentStep == 2) {
    if (_formKey.currentState!.validate()) {
        _handlePaymentProcessing();
    } else {
        _showSnackBar('Preencha todos os dados corretamente para gerar o Pix.', isError: true);
    }
} else if (_currentStep == 3) {
    if (_pixResponse != null && mounted && Navigator.canPop(context)) {
        Navigator.pop(context, true); 
    }
  }
  }

  void _onStepCancel() {
  setState(() {
    if (_currentStep > 0) {
      _currentStep -= 1;
    } else {
      Navigator.pop(context);
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Ticket>>(
        future: widget.apiService.fetchTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar comandas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().split(':').last.trim(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          final availableTickets = snapshot.data!;

          if (availableTickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma comanda disponível',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          Ticket? ticketToSelect;

          if (widget.preSelectedTicket != null) {
            ticketToSelect = availableTickets.firstWhere(
                  (t) => t.id == widget.preSelectedTicket!.id,
              orElse: () => availableTickets.first,
            );
          } else if (_selectedTicket == null) {
            ticketToSelect = availableTickets.first;
          }

          if (ticketToSelect != null && _selectedTicket != ticketToSelect) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedTicket = ticketToSelect;
                  _ticketDetail = null;
                });
                _startFetchingDetails(ticketToSelect!);
              }
            });
          }

          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              steps: _buildSteps(availableTickets),
              controlsBuilder: (context, details) {
                final isLastStep = details.currentStep == 1;
                final isFirstStep = details.currentStep == 0;


                if (isFirstStep) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: details.onStepContinue,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }


                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    children: <Widget>[

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: details.onStepCancel,
                          icon: const Icon(Icons.arrow_back),
                          label: Text(
                            isLastStep ? 'Voltar' : 'Cancelar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
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


                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: details.onStepContinue,
                          icon: Icon(
                            isLastStep ? Icons.check_circle : Icons.arrow_forward,
                          ),
                          label: Text(
                            isLastStep ? 'Finalizar Pagamento' : 'Continuar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLastStep
                                ? Colors.green.shade600
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
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
}