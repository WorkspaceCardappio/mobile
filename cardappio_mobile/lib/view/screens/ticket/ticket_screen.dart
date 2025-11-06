import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/api_service.dart';
import '../../../model/ticket.dart';
import '../payment/payment_screen.dart';
import 'ticket_detail_screen.dart';

class TicketScreen extends StatefulWidget {
  final ApiService apiService;

  const TicketScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {

  int _refreshKey = 0;

  void _reloadTickets() {
    setState(() {
      _refreshKey++;
    });
  }

  void _navigateToPaymentWithTicket(Ticket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          preSelectedTicket: ticket,
          apiService: widget.apiService,
        ),
      ),
    );
  }


  void _openTicketDetails(Ticket ticket) async {
    final bool? shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailScreen(
          ticket: ticket,
          apiService: widget.apiService,
          onNavigateToPayment: _navigateToPaymentWithTicket,
        ),
      ),
    );


    if (shouldReload == true) {
      _reloadTickets();
    }
  }

  // ⭐️ NOVO WIDGET: Ícone de Comanda Sutil (Substituindo o Stack complexo)
  Widget _buildTicketLeading(BuildContext context, int ticketNumber) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1), // Fundo suave
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '#${ticketNumber}',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // ⭐️ COR SECUNDÁRIA MODERNA: Verde claro sóbrio
    final Color modernGreen = Colors.green.shade400;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comandas Abertas',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
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
            key: ValueKey(_refreshKey),
            future: widget.apiService.fetchTickets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState(context, snapshot.error!);
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final tickets = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  // Formato de data mais limpo (sem segundos)
                  final dateFormat = DateFormat('dd/MM/yyyy • HH:mm');
                  final formattedDate = dateFormat.format(ticket.createdAt);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

                      // ⭐️ LEADING: Ícone de número customizado
                      leading: _buildTicketLeading(context, ticket.number),

                      // ⭐️ TÍTULO PROFISSIONAL E LIMPO
                      // title: Text(
                      //   'Comanda #${ticket.number}',
                      //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      //     fontWeight: FontWeight.w600,
                      //     fontSize: 17,
                      //   ),
                      // ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ⭐️ DESTAQUE DO TOTAL (Verde Moderno)
                          Text(
                            'Total: R\$ ${ticket.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: modernGreen, // ⭐️ Aplicação da nova cor
                            ),
                          ),
                          const SizedBox(height: 4),
                          // DATA FORMATADA
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: modernGreen, // ⭐️ Aplicação da nova cor
                      ),
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

  // Métodos de estado de erro e vazio (mantidos)

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
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.grey[700],
              ),
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
          const Text(
            'Nenhuma Comanda Aberta.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicie um pedido na Home para criar uma comanda.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}