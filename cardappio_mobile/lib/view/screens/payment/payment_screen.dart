import 'package:flutter/material.dart';
import '../../../data/api_service.dart';
import '../../../model/ticket.dart';
// Note: O import de TicketItem foi mantido
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
  double _partialAmount = 0.0;
  final TextEditingController _partialController = TextEditingController();

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

  Future<TicketDetail> _fetchTicketDetails(Ticket ticket) async {
    return await widget.apiService.fetchTicketDetails(ticket);
  }

  void _updatePartialAmount(double total) {
    setState(() {
      _partialAmount = total;
      _partialController.text = total.toStringAsFixed(2);
    });
  }

  void _handlePaymentProcessing() async {
    final double grandTotal = _ticketDetail?.calculatedTotal ?? 0.0;

    if (_selectedTicket == null || _ticketDetail == null || grandTotal == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comanda não selecionada ou detalhes não carregados.'),
        ),
      );
      return;
    }

    double amountToPay = 0.0;
    if (_paymentOption == 'total') {
      amountToPay = grandTotal;
    } else {
      amountToPay =
          double.tryParse(_partialController.text.replaceAll(',', '.')) ?? 0.0;
      if (amountToPay <= 0 || amountToPay > grandTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valor parcial inválido.')),
        );
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Processando pagamento de R\$ ${amountToPay.toStringAsFixed(2)} para Comanda #${_selectedTicket!.id}...',
        ),
      ),
    );

    final result = await widget.apiService.payTicket(_selectedTicket!.id);

    if (!mounted) return;
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Pagamento realizado com sucesso!')),
      );

      if (_paymentOption == 'total') {
        setState(() {
          _selectedTicket = null;
          _ticketDetail = null;
          _currentStep = 0;
        });
      }

      if (widget.preSelectedTicket != null && Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Falha na transação. Tente novamente.'),
        ),
      );
    }
  }

  Widget _buildStep1SelectTicket(List<Ticket> availableTickets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        DropdownButtonFormField<Ticket>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelText: 'Comanda a Pagar',
          ),
          value: _selectedTicket,
          items: availableTickets.map((ticket) {
            return DropdownMenuItem(
              value: ticket,
              child: Text(
                'Comanda: ${ticket.number} - Total: R\$ ${ticket.total.toStringAsFixed(2)}',
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
          hint: const Text('Selecione uma comanda'),
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
          return const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Erro ao carregar detalhes: ${snapshot.error.toString().split(':').last.trim()}',
              style: const TextStyle(color: Colors.red),
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

  // ⭐️ MÉTODO CORRIGIDO PARA A NOVA HIERARQUIA (orders -> items)
  Widget _buildTicketDetailConfirmation(TicketDetail detail) {
    final double grandTotal = detail.calculatedTotal;

    // ⭐️ CORREÇÃO: Usamos .expand e .cast<ProductOrder>() para garantir a tipagem não-nula.
    // Assumimos que a classe ProductOrder está definida e disponível (ou que TicketItem foi renomeado para ProductOrder).
    final List<ProductOrder> allProducts =
    detail.orders.expand((order) => order.items).cast<ProductOrder>().toList();

    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comanda ${detail.number}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Itens na Comanda:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // ⭐️ Itera sobre a lista tipada
            ...allProducts.map((item) {
              // Agora, item é garantido como ProductOrder não-nulo, e as propriedades podem ser acessadas diretamente.
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        // Propriedades não-nulas de ProductOrder
                        '${item.quantity}x ${item.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      // Propriedade não-nula de ProductOrder
                      'R\$ ${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Geral:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'R\$ ${grandTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 24,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2PaymentOptions() {
    if (_ticketDetail == null) {
      return const Center(child: Text('Carregando detalhes da comanda...'));
    }

    final double grandTotal = _ticketDetail!.calculatedTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comanda: ${_ticketDetail!.number} | Total: R\$ ${grandTotal.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const Divider(height: 25),
        Text(
          'Selecione o Tipo de Pagamento:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        RadioListTile<String>(
          title: const Text('Pagamento Total'),
          value: 'total',
          groupValue: _paymentOption,
          onChanged: (value) => setState(() {
            _paymentOption = value!;
            _updatePartialAmount(grandTotal);
          }),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        RadioListTile<String>(
          title: const Text('Pagamento Parcial'),
          value: 'partial',
          groupValue: _paymentOption,
          onChanged: (value) => setState(() => _paymentOption = value!),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        if (_paymentOption == 'partial')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextFormField(
              controller: _partialController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText:
                'Valor a Pagar (Máx: R\$ ${grandTotal.toStringAsFixed(2)})',
                prefixText: 'R\$ ',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
      ],
    );
  }

  List<Step> _buildSteps(List<Ticket> availableTickets) {
    return [
      Step(
        title: const Text('Selecionar e Conferir Comanda'),
        content: _buildStep1SelectTicket(availableTickets),
        isActive: _currentStep == 0,
        state: _selectedTicket != null && _ticketDetail != null
            ? StepState.complete
            : StepState.editing,
      ),
      Step(
        title: const Text('Opções e Finalização'),
        content: _buildStep2PaymentOptions(),
        isActive: _currentStep == 1,
        state: StepState.editing,
      ),
    ];
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_selectedTicket != null && _ticketDetail != null) {
        setState(() => _currentStep = 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, carregue e confirme a comanda primeiro.'),
          ),
        );
      }
    } else {
      _handlePaymentProcessing();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processar Pagamento'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: FutureBuilder<List<Ticket>>(
        future: widget.apiService.fetchTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Erro ao carregar comandas: ${snapshot.error.toString().split(':').last.trim()}',
              ),
            );
          }

          final availableTickets = snapshot.data!;

          Ticket? ticketToSelect;

          if (widget.preSelectedTicket != null) {
            ticketToSelect = availableTickets.firstWhere(
                  (t) => t.id == widget.preSelectedTicket!.id,
              orElse: () => availableTickets.first,
            );
          } else if (_selectedTicket == null && availableTickets.isNotEmpty) {
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

          return Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            steps: _buildSteps(availableTickets),
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: details.onStepContinue,
                      icon: Icon(
                        details.currentStep == 0
                            ? Icons.chevron_right_rounded
                            : Icons.check_circle,
                      ),
                      label: Text(
                        details.currentStep == 0
                            ? '    Confirmar    '
                            : ' Finalizar Pagamento',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: details.currentStep == 0
                            ? Theme.of(context).colorScheme.primary
                            : Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
          );
        },
      ),
    );
  }
}