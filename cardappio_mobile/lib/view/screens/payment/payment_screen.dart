import 'package:flutter/material.dart';

import '../../../data/api_service.dart';
import '../../../model/ticket.dart';


class PaymentScreen extends StatefulWidget {
  final Ticket? preSelectedTicket;

  const PaymentScreen({super.key, this.preSelectedTicket});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<List<Ticket>>? _ticketsFuture;
  Ticket? _selectedTicket;
  String _paymentOption = 'total';
  double _partialAmount = 0.0;
  final TextEditingController _partialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticketsFuture = ApiService.fetchTickets();
    _selectedTicket = widget.preSelectedTicket;

    if (_selectedTicket != null) {
      _updatePartialAmount(_selectedTicket!.total);
    }
  }

  @override
  void dispose() {
    _partialController.dispose();
    super.dispose();
  }

  void _updatePartialAmount(double total) {
    setState(() {
      _partialAmount = total;
      _partialController.text = total.toStringAsFixed(2);
    });
  }

  void _handlePaymentProcessing() async {
    if (_selectedTicket == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma comanda primeiro.')));
      return;
    }

    double amountToPay = 0.0;
    if (_paymentOption == 'total') {
      amountToPay = _selectedTicket!.total;
    } else {
      amountToPay = double.tryParse(_partialController.text.replaceAll(',', '.')) ?? 0.0;
      if (amountToPay <= 0 || amountToPay > _selectedTicket!.total) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valor parcial inválido.')));
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Processando pagamento de R\$ ${amountToPay.toStringAsFixed(2)} para Comanda #${_selectedTicket!.id}...'),
    ));

    final result = await ApiService.payTicket(_selectedTicket!.id);

    if (!mounted) return;
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Pagamento realizado com sucesso!')));

      if (_paymentOption == 'total') {
        setState(() {
          _selectedTicket = null;
          _ticketsFuture = ApiService.fetchTickets();
        });
      }

      if (widget.preSelectedTicket != null && Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Falha na transação. Tente novamente.')));
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
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Erro ao carregar comandas: ${snapshot.error.toString().split(':').last.trim()}'));
          }

          final availableTickets = snapshot.data!;

          if (widget.preSelectedTicket != null && _selectedTicket == null && availableTickets.isNotEmpty) {
            _selectedTicket = availableTickets.firstWhere(
                  (t) => t.id == widget.preSelectedTicket!.id,
              orElse: () => availableTickets.first,
            );
            if (_selectedTicket != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updatePartialAmount(_selectedTicket!.total);
              });
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Selecione a Comanda', style: Theme.of(context).textTheme.titleLarge),
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
                      child: Text('Mesa ${ticket.tableNumber} - Total: R\$ ${ticket.total.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                  onChanged: (Ticket? newValue) {
                    setState(() {
                      _selectedTicket = newValue;
                      if (_selectedTicket != null) {
                        _updatePartialAmount(_selectedTicket!.total);
                        _paymentOption = 'total';
                      }
                    });
                  },
                  hint: const Text('Selecione uma comanda'),
                ),
                const Divider(height: 40),

                Text('2. Tipo de Pagamento', style: Theme.of(context).textTheme.titleLarge),

                if (_selectedTicket != null) ...[
                  RadioListTile<String>(
                    title: Text('Pagamento Total (R\$ ${_selectedTicket!.total.toStringAsFixed(2)})'),
                    value: 'total',
                    groupValue: _paymentOption,
                    onChanged: (value) => setState(() {
                      _paymentOption = value!;
                      _updatePartialAmount(_selectedTicket!.total);
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
                ],

                if (_paymentOption == 'partial' && _selectedTicket != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextFormField(
                      controller: _partialController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Valor a Pagar (Máx: R\$ ${_selectedTicket!.total.toStringAsFixed(2)})',
                        prefixText: 'R\$ ',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedTicket != null ? _handlePaymentProcessing : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      _selectedTicket == null
                          ? 'Selecione a Comanda'
                          : (_paymentOption == 'total' ? 'Finalizar Pagamento Total' : 'Pagar R\$ ${_partialController.text}'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}