import 'package:flutter/material.dart';
import '../../../data/api_service.dart';
import '../../../model/ticket.dart';
import '../../../model/ticket_item.dart';

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

  // ⭐️ Método NOVO/CORRIGIDO: Inicia a requisição e armazena o Future.
  void _startFetchingDetails(Ticket ticket) {
    // 1. Inicia a requisição da API
    final future = widget.apiService.fetchTicketDetails(ticket);

    // 2. Armazena o Future na variável de estado
    setState(() {
      _ticketDetailFuture = future.then((detail) {
        // 3. Quando o Future completa, atualiza o estado com os detalhes
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _ticketDetail = detail;
                _updatePartialAmount(detail.total);
              });
            }
          });
        }
        return detail;
      });
    });
  }

  // Mantido para compatibilidade, apenas retorna o Future.
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
    // Lógica de processamento de pagamento...
    if (_selectedTicket == null || _ticketDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comanda não selecionada ou detalhes não carregados.'),
        ),
      );
      return;
    }

    double amountToPay = 0.0;
    if (_paymentOption == 'total') {
      amountToPay = _ticketDetail!.total;
    } else {
      amountToPay =
          double.tryParse(_partialController.text.replaceAll(',', '.')) ?? 0.0;
      if (amountToPay <= 0 || amountToPay > _ticketDetail!.total) {
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
        Text(
          'Selecione a comanda para visualizar os detalhes:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
              // ⭐️ Inicia a requisição ao mudar o Dropdown
              _startFetchingDetails(newValue);
            }
          },
          hint: const Text('Selecione uma comanda'),
        ),
        _buildTicketDetailsLoader(),
      ],
    );
  }

  // ⭐️ CORREÇÃO: FutureBuilder agora usa _ticketDetailFuture
  Widget _buildTicketDetailsLoader() {
    if (_ticketDetailFuture == null) {
      return const SizedBox.shrink(); // Nada para carregar ainda
    }

    return FutureBuilder<TicketDetail>(
      future: _ticketDetailFuture, // Usa o Future armazenado no estado
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

        // Usa _ticketDetail, que foi preenchido no .then()
        if (snapshot.hasData && _ticketDetail != null) {
          return _buildTicketDetailConfirmation(_ticketDetail!); // ⭐️ Método corrigido
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ⭐️ Método RESTAURADO/CORRIGIDO: _buildTicketDetailConfirmation
  Widget _buildTicketDetailConfirmation(TicketDetail detail) {
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
                Text(
                  'Comanda #${detail.id.substring(0, 4)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Itens na Comanda:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...detail.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.productName}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'R\$ ${item.subtotal.toStringAsFixed(2)}',
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
                  'R\$ ${detail.total.toStringAsFixed(2)}',
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

  // ⭐️ Método RESTAURADO: _buildStep2PaymentOptions
  Widget _buildStep2PaymentOptions() {
    if (_ticketDetail == null) {
      return const Center(child: Text('Carregando detalhes da comanda...'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comanda: ${_ticketDetail!.number} | Total: R\$ ${_ticketDetail!.total.toStringAsFixed(2)}',
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
            _updatePartialAmount(_ticketDetail!.total);
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
                'Valor a Pagar (Máx: R\$ ${_ticketDetail!.total.toStringAsFixed(2)})',
                prefixText: 'R\$ ',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
      ],
    );
  }

  // ⭐️ Método RESTAURADO: _buildSteps
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

  // ⭐️ Método RESTAURADO: _onStepContinue
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

  // ⭐️ Método RESTAURADO: _onStepCancel
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

          // Se encontramos um ticket para selecionar E ele é diferente do ticket atual,
          // fazemos o setState e iniciamos a busca.
          if (ticketToSelect != null && _selectedTicket != ticketToSelect) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedTicket = ticketToSelect;
                  _ticketDetail = null; // Limpa o detalhe antigo
                });
                // ⭐️ CORREÇÃO: Checa se é nulo antes de passar para _startFetchingDetails
                _startFetchingDetails(ticketToSelect!);
              }
            });
          }

          return Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _onStepContinue, // ⭐️ Método corrigido
            onStepCancel: _onStepCancel,     // ⭐️ Método corrigido
            steps: _buildSteps(availableTickets), // ⭐️ Método corrigido
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: details.onStepContinue,

                      label: Text(
                        details.currentStep == 0
                            ? '    Confirmar    '
                            : 'Finalizar Pagamento',
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