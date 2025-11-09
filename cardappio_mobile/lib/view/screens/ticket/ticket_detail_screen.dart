import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/api_service.dart';
import '../../../model/ticket.dart';
import '../../common/split_ticket_dialog.dart';
import '../../../model/ticket_item.dart' hide ProductOrder;

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;
  final ApiService apiService;
  final Function(Ticket ticket) onNavigateToPayment;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
    required this.apiService,
    required this.onNavigateToPayment,
  });

  static final Color modernGreen = Colors.green.shade600;
  static final Color splitColor = Colors.orange.shade600;

  void _handleSplitTicket(BuildContext context, TicketDetail detail) async {
    final bool? splitSuccess = await showDialog<bool>(
      context: context,
      builder: (context) => SplitTicketDialog(
        currentTicket: detail,
        apiService: apiService,
      ),
    );

    if (splitSuccess == true) {
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Comanda ${ticket.number}',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black87,
      ),
      body: FutureBuilder<TicketDetail>(
        future: apiService.fetchTicketDetails(ticket),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar detalhes: ${snapshot.error.toString().split(':').last.trim()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final TicketDetail? detail = snapshot.data;

          if (detail == null) {
            return const Center(
              child: Text('Detalhes da comanda não encontrados.'),
            );
          }

          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
          final formattedDate = dateFormat.format(detail.createdAt);

          return Column(
            children: [
              _buildHeader(context, detail, formattedDate),
              _buildItemsHeader(context, detail),
              Expanded(child: _buildItemsList(context, detail)),
              _buildActionButtons(context, detail),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      TicketDetail detail,
      String formattedDate,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comanda Aberta em: $formattedDate',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total a Pagar:',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                'R\$ ${detail.calculatedTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: modernGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsHeader(BuildContext context, TicketDetail detail) {
    final totalItemCount = detail.orders.expand((order) => order.items).length;

    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        'ITENS PEDIDOS ($totalItemCount)',
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, TicketDetail detail) {
    final List<ProductOrder> allProducts =
    detail.orders.expand((order) => order.items).toList().cast<ProductOrder>();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
        itemCount: allProducts.length,
        itemBuilder: (context, index) {
          final item = allProducts[index];

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${item.quantity}x',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'R\$ ${item.price.toStringAsFixed(2)} / un.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                Text(
                  'R\$ ${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: modernGreen,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TicketDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSplitButton(context, detail),
          const SizedBox(width: 16),
          _buildPaymentButton(context, detail),
        ],
      ),
    );
  }

  Widget _buildSplitButton(BuildContext context, TicketDetail detail) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _handleSplitTicket(context, detail),
        icon: const Icon(Icons.call_split, size: 24),
        label: const Text('Dividir'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context, TicketDetail detail) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => onNavigateToPayment(ticket),
        icon: const Icon(Icons.payment, size: 24),
        label: Text('Pagar (R\$ ${detail.calculatedTotal.toStringAsFixed(2)})'),
        style: ElevatedButton.styleFrom(
          backgroundColor: modernGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          elevation: 3,
        ),
      ),
    );
  }
}