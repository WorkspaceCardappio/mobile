import 'package:cardappio_mobile/view/screens/ticket/ticket_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/api_service.dart';
import '../../../model/ticket.dart';
import '../payment/payment_screen.dart';


class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  Future<List<Ticket>>? _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = ApiService.fetchTickets();
  }

  void _reloadTickets() {
    setState(() {
      _ticketsFuture = ApiService.fetchTickets();
    });
  }

  void _navigateToPaymentWithTicket(Ticket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(preSelectedTicket: ticket),
      ),
    );
  }

  void _openTicketDetails(Ticket ticket) async {
    // Retorna true se a PaymentScreen pagou a comanda e a TicketScreen precisa recarregar
    final bool? shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailScreen(ticket: ticket, onNavigateToPayment: _navigateToPaymentWithTicket),
      ),
    );

    if (shouldReload == true) {
      _reloadTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comandas Abertas',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 28),
                onPressed: _reloadTickets,
                tooltip: 'Recarregar Comandas',
              ),
            ],
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child: FutureBuilder<List<Ticket>>(
            future: _ticketsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _buildErrorState(context, snapshot.error!);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final tickets = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
                  final formattedDate = dateFormat.format(ticket.createdAt);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(ticket.number.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('Comanda #${ticket.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('Mesa: ${ticket.number} - Total: R\$ ${ticket.total.toStringAsFixed(2)}\nAberta em: $formattedDate'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.secondary),
                      onTap: () => _openTicketDetails(ticket),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
            const SizedBox(height: 15),
            Text(
              'Erro ao Carregar Comandas.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Detalhes: ${error.toString().split(':').last.trim()}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _reloadTickets,
              icon: const Icon(Icons.replay),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('Nenhuma Comanda Aberta.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Inicie um pedido na Home para criar uma comanda.', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}