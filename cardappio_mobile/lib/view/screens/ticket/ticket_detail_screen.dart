import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../../../data/api_service.dart';
import '../../../model/ticket.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  final Function(Ticket ticket) onNavigateToPayment;

  const TicketDetailScreen({super.key, required this.ticket, required this.onNavigateToPayment});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Future<TicketDetail>? _ticketDetailFuture;

  @override
  void initState() {
    super.initState();
    _ticketDetailFuture = ApiService.fetchTicketDetails(widget.ticket.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comanda #${widget.ticket.id} - Mesa ${widget.ticket.number}', style: const TextStyle(fontSize: 18)),
        elevation: 1,
      ),
      body: FutureBuilder<TicketDetail>(
        future: _ticketDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar detalhes: ${snapshot.error.toString().split(':').last.trim()}', textAlign: TextAlign.center),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Detalhes da comanda não encontrados.'));
          }

          final detail = snapshot.data!;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
          final formattedDate = dateFormat.format(detail.createdAt);

          return Column(
            children: [
              _buildHeader(context, detail, formattedDate),
              const Divider(),
              _buildItemsHeader(context, detail),
              Expanded(child: _buildItemsList(context, detail)),
              _buildPaymentButton(context, detail),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TicketDetail detail, String formattedDate) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data de Abertura: $formattedDate', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Total da Comanda:', style: Theme.of(context).textTheme.titleLarge),
          Text('R\$ ${detail.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildItemsHeader(BuildContext context, TicketDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text('Itens Pedidos (${detail.items.length}):', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
    );
  }

  Widget _buildItemsList(BuildContext context, TicketDetail detail) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: detail.items.length,
      itemBuilder: (context, index) {
        final item = detail.items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
            ),
            title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('R\$ ${item.unitPrice.toStringAsFixed(2)} / un.'),
            trailing: Text(
              'R\$ ${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentButton(BuildContext context, TicketDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
      ),
      child: ElevatedButton.icon(
        onPressed: () => widget.onNavigateToPayment(widget.ticket),
        icon: const Icon(Icons.payment),
        label: Text('Pagar Comanda (R\$ ${detail.total.toStringAsFixed(2)})'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}