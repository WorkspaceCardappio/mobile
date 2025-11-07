import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../../model/split_orders_dto.dart';
import '../../model/ticket.dart';
// Note: ticket_item.dart (ou ProductOrder) não é mais usado diretamente aqui

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
  // ⭐️ Armazena o ID do PEDIDO (Order ID) selecionado
  final Set<String> _selectedOrderKeys = {};

  final String? _selectedDestinationTicketId = null;

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
      if (_selectedOrderKeys.contains(orderId)) {
        _selectedOrderKeys.remove(orderId);
      } else {
        _selectedOrderKeys.add(orderId);
      }
    });
  }

  Future<void> _handleSplit() async {
    if (_selectedOrderKeys.isEmpty) {
      _showSnackBar('Selecione ao menos um pedido para dividir.');
      return;
    }

    // ⭐️ CORRIGIDO: Validação compara com o total de PEDIDOS (orders), não itens.
    if (_selectedOrderKeys.length == widget.currentTicket.orders.length) {
      _showSnackBar('Não é permitido dividir todos os pedidos da comanda.');
      return;
    }

    // Os IDs selecionados JÁ são os Order IDs que o backend espera.
    final Set<String> realOrderIds = _selectedOrderKeys;

    final splitData = SplitOrdersDTO(
      orders: realOrderIds, // Enviando os IDs dos PEDIDOS (Order IDs)
      ticket: null,
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

  // ------------------------------------------
  // WIDGETS DE CONSTRUÇÃO
  // ------------------------------------------

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
                'Comanda de Origem: ${widget.currentTicket.number} | Total: R\$ ${widget.currentTicket.calculatedTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              Text(
                // Texto ajustado para refletir a divisão por Pedido
                'Selecione os **pedidos completos** a serem movidos para uma nova comanda:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildOrdersList(), // ⭐️ Chamando o método correto
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedOrderKeys.isEmpty ? null : _handleSplit,
          child: const Text('Confirmar Divisão'),
        ),
      ],
    );
  }

  // ⭐️ NOVO MÉTODO: Constrói a lista iterando sobre AggregatedOrder
  Widget _buildOrdersList() {
    return Column(
      // ⭐️ Itera sobre a lista de PEDIDOS (orders)
      children: widget.currentTicket.orders.map((order) {
        final uniqueKey = order.orderId;
        final isSelected = _selectedOrderKeys.contains(uniqueKey);

        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) => _toggleItemSelection(uniqueKey),
          // ⭐️ TÍTULO CORRIGIDO: Exibe o resumo dos produtos (X-Tudo E Refrigerante)
          title: Text(order.summary),
          // ⭐️ SUBTITLE CORRIGIDO: Exibe o subtotal do PEDIDO inteiro
          subtitle: Text(
              'Subtotal do Pedido: R\$ ${order.subtotal.toStringAsFixed(2)}'),
          controlAffinity: ListTileControlAffinity.leading,
          tileColor: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        );
      }).toList(),
    );
  }
}