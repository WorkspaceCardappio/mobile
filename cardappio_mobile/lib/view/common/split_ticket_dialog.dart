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
  final Set<String> _selectedOrderKeys = {};

  // Mantemos o destino nulo, indicando ao backend para criar um novo ticket.
  final String? _selectedDestinationTicketId = null;

  // Mantemos _availableTickets e _isLoading apenas se forem usados em outras partes
  // do initState (embora não sejam mais necessários para a UI de destino).
  // Se _fetchAvailableTickets não for mais necessário, ele pode ser removido,
  // mas o mantemos para evitar quebras em outras partes.
  List<Ticket> _availableTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Chamada mantida caso seja necessária para outras validações futuras.
    _fetchAvailableTickets();
  }

  // Método mantido, mas não afeta a UI de destino.
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

  void _toggleItemSelection(String uniqueKey) {
    setState(() {
      if (_selectedOrderKeys.contains(uniqueKey)) {
        _selectedOrderKeys.remove(uniqueKey);
      } else {
        _selectedOrderKeys.add(uniqueKey);
      }
    });
  }

  Future<void> _handleSplit() async {
    if (_selectedOrderKeys.isEmpty) {
      _showSnackBar('Selecione ao menos um item para dividir.');
      return;
    }

    if (_selectedOrderKeys.length == widget.currentTicket.items.length) {
      _showSnackBar('Não é permitido dividir todos os itens da comanda.');
      return;
    }

    // Extrai o ID real. Como o modelo TicketItem agora tem o Order ID real (ou ProductOrder ID),
    // a lógica de split no backend deve funcionar.
    final realOrderIds = _selectedOrderKeys
        .map((key) => key.split('_').first)
        .where((id) => id.isNotEmpty)
        .toSet();

    if (realOrderIds.isEmpty) {
      _showSnackBar('Os itens selecionados não possuem um ID de pedido válido.');
      return;
    }

    // O destino é sempre nulo, forçando a criação de um novo ticket no backend.
    final splitData = SplitOrdersDTO(
      orders: realOrderIds,
      ticket: null, // Destino fixo: Criar Nova Comanda
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

              // ❌ REMOVIDO: Seção "Mover para:"
              // const Divider(height: 20),
              // Text('Mover para:', style: Theme.of(context).textTheme.titleSmall),
              // const SizedBox(height: 8),
              // _buildDestinationSelector(), // Método removido abaixo
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
      children: widget.currentTicket.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        // Cria a chave única: ID do pedido/produto + índice
        final uniqueKey = '${item.id}_$index';

        // Usa o Set de chaves corrigido
        final isSelected = _selectedOrderKeys.contains(uniqueKey);

        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) => _toggleItemSelection(uniqueKey), // Usa a chave única
          title: Text('${item.quantity}x ${item.productName}'),
          subtitle: Text('R\$ ${item.subtotal.toStringAsFixed(2)}'),
          controlAffinity: ListTileControlAffinity.leading,
          tileColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
        );
      }).toList(),
    );
  }

// ❌ REMOVIDO: Método _buildDestinationSelector não é mais necessário.
/*
  Widget _buildDestinationSelector() {
    return const SizedBox.shrink();
  }
  */
}