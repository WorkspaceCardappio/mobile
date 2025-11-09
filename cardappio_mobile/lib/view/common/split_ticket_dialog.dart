import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../../model/split_orders_dto.dart';
import '../../model/ticket.dart';

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
  bool _isProcessingSplit = false;

  @override
  void initState() {
    super.initState();

  }

  void _toggleOrderSelection(String orderId) {
    if (_isProcessingSplit) return;

    setState(() {
      if (_selectedOrderIds.contains(orderId)) {
        _selectedOrderIds.remove(orderId);
      } else {
        _selectedOrderIds.add(orderId);
      }
    });
  }

  Future<void> _handleSplit() async {
    final int totalOrders = widget.currentTicket.orders.length;

    if (_selectedOrderIds.isEmpty) {
      _showSnackBar('Selecione ao menos um pedido para divisão.', isError: false);
      return;
    }

    if (_selectedOrderIds.length == totalOrders) {
      _showSnackBar('Não é permitido mover todos os pedidos. Um pedido deve permanecer na comanda original.', isError: true);
      return;
    }

    setState(() => _isProcessingSplit = true);


    final SplitOrdersDTO splitData = SplitOrdersDTO(
      orders: _selectedOrderIds,
      ticket: null,
    );

    try {
      await widget.apiService.splitTicket(
        widget.currentTicket.id,
        splitData,
      );

      _showSnackBar('✅ Divisão realizada com sucesso!');
      if (mounted) {
        Navigator.pop(context, true);

      }
    } catch (e) {
      _showSnackBar('❌ Erro na divisão: ${e.toString().split(':').last.trim()}', isError: true);
    } finally {
      setState(() => _isProcessingSplit = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    'Comanda: #${widget.currentTicket.number}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary, // Usa Primary Color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: R\$ ${widget.currentTicket.calculatedTotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(height: 32, thickness: 1, color: Colors.grey.shade300),

                  Text(
                    '(Será criada uma nova comanda a partir dos pedidos selecionados.)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildOrdersList(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Cor Primária do Tema
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dividir Comanda',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (widget.currentTicket.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Nenhum pedido disponível para divisão.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color accentColor = Colors.orange.shade600;


    return Column(
      children: widget.currentTicket.orders.map((order) {
        final uniqueKey = order.orderId;
        final isSelected = _selectedOrderIds.contains(uniqueKey);

        return Card(
          elevation: isSelected ? 4 : 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? accentColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: _isProcessingSplit ? null : () => _toggleOrderSelection(uniqueKey),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
                    color: isSelected ? accentColor : Colors.grey.shade400,
                    size: 28,
                  ),
                  const SizedBox(width: 16),


                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.summary,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),


                  Text(
                    'R\$ ${order.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool canProceed = _selectedOrderIds.isNotEmpty &&
        _selectedOrderIds.length < widget.currentTicket.orders.length;

    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isProcessingSplit ? null : () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (canProceed && !_isProcessingSplit) ? _handleSplit : null,
              icon: _isProcessingSplit
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.send_rounded, size: 24),
              label: Text(_isProcessingSplit ? 'Processando...' : 'Criar Nova Comanda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}