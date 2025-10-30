import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../../model/ticket.dart';

class TicketSelectionDialog extends StatefulWidget {
  const TicketSelectionDialog({super.key});

  @override
  State<TicketSelectionDialog> createState() => _TicketSelectionDialogState();
}

class _TicketSelectionDialogState extends State<TicketSelectionDialog> {

  final ApiService _apiService = ApiService();
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _apiService.fetchTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selecione a Comanda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: FutureBuilder<List<Ticket>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Falha ao carregar comandas. Tente novamente.',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Nenhuma comanda disponível para seleção.'),
                    ),
                  );
                }

                final tickets = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: tickets.length,
                  separatorBuilder: (context, index) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop(ticket);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Comanda #${ticket.number}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCELAR'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}