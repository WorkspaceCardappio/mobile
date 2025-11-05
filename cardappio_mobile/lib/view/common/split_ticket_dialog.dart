

import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../../model/split_orders_dto.dart';
import '../../model/ticket.dart';
import '../../model/ticket_item.dart';

class SplitTicketDialog extends StatefulWidget {
  final TicketDetail currentTicket;
  final ApiService apiService;

  const SplitTicketDialog({
    super.key,
    required this.currentTicket,
    required this.apiService,
  });

  @override
  State<SplitTicketDialog> createState() => _SplitTicketDialogState();
}

class _SplitTicketDialogState extends State<SplitTicketDialog> {
  final Set<String> _selectedOrderIds = {};
  String? _selectedDestinationTicketId;
  List<Ticket> _availableTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableTickets();
  }

  Future<void> _fetchAvailableTickets() async {
    try {
      final allTickets = await widget.apiService.fetchTickets();

      setState(() {
        _availableTickets =
            allTickets.where((t) => t.id != widget.currentTicket.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar destinos: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleItemSelection(String orderId) {
    setState(() {
      if (_selectedOrderIds.contains(orderId)) {
        _selectedOrderIds.remove(orderId);
      } else {
        _selectedOrderIds.add(orderId);
      }
    });
  }

  Future<void> _handleSplit() async {
    if (_selectedOrderIds.isEmpty) {
      _showSnackBar('Selecione ao menos um item para dividir.');
      return;
    }


    if (_selectedOrderIds.length == widget.currentTicket.items.length) {
      _showSnackBar('Não é permitido dividir todos os itens da comanda.');
      return;
    }

    final splitData = SplitOrdersDTO(
      orders: _selectedOrderIds,
      ticket: _selectedDestinationTicketId,
    );

    try {
      await widget.apiService.splitTicket(
        widget.currentTicket.id,
        splitData,
      );

      _showSnackBar('✅ Comanda dividida com sucesso!');

      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('❌ Erro na divisão: ${e.toString().split(':').last.trim()}');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dividir Comanda'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500, // Limita a largura do modal
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comanda de Origem: #${widget.currentTicket.id} (Mesa ${widget.currentTicket.number})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),


              Text('Selecione os itens a serem movidos:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildItemsList(),
              const Divider(height: 20),


              Text('Mover para:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildDestinationSelector(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Cancelar
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSplit,
          child: const Text('Confirmar Divisão'),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: widget.currentTicket.items.map((item) {
        final isSelected = _selectedOrderIds.contains(item.id);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) => _toggleItemSelection(item.id),
          title: Text('${item.quantity}x ${item.productName}'),
          subtitle: Text('R\$ ${item.subtotal.toStringAsFixed(2)}'),
          controlAffinity: ListTileControlAffinity.leading,
          tileColor: isSelected ? Colors.blue.shade50 : null,
        );
      }).toList(),
    );
  }

  Widget _buildDestinationSelector() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String?>(
          title: const Text('Criar Nova Comanda'),
          value: null,
          groupValue: _selectedDestinationTicketId,
          onChanged: (value) => setState(() => _selectedDestinationTicketId = value),
        ),
        const Divider(height: 1),
        RadioListTile<String?>(
          title: Text('Comanda Existente (${_availableTickets.length} disponíveis)'),
          value: 'select', // Valor temporário para abrir o dropdown
          groupValue: _selectedDestinationTicketId != null ? 'select' : null,
          onChanged: (value) {
            if (value == 'select') {
              setState(() => _selectedDestinationTicketId = _availableTickets.isNotEmpty ? _availableTickets.first.id : null);
            }
          },
        ),
        if (_selectedDestinationTicketId != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Selecione a Comanda Destino',
              ),
              value: _selectedDestinationTicketId,
              items: _availableTickets.map((ticket) {
                return DropdownMenuItem(
                  value: ticket.id,
                  child: Text(
                    'Mesa ${ticket.number} - Total: R\$ ${ticket.total.toStringAsFixed(2)}',
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDestinationTicketId = newValue;
                });
              },
            ),
          ),
      ],
    );
  }
}