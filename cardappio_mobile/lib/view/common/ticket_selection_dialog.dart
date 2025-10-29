import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../../model/ticket.dart';

class TicketSelectionDialog extends StatefulWidget {
  const TicketSelectionDialog({super.key});

  @override
  State<TicketSelectionDialog> createState() => _TicketSelectionDialogState();
}

class _TicketSelectionDialogState extends State<TicketSelectionDialog> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = ApiService.fetchTickets();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione uma Comanda'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<Ticket>>(
          future: _ticketsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao buscar comandas: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma comanda disponível.'));
            }

            final tickets = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return ListTile(
                  title: Text('Comanda #${ticket.number}'),
                  onTap: () {
                    // Retorna a comanda selecionada para quem chamou o dialog
                    Navigator.of(context).pop(ticket);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop(); // Retorna null
          },
        ),
      ],
    );
  }
}