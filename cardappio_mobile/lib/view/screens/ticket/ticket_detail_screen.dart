import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/api_service.dart';
import '../../../model/ticket.dart';
import '../../common/split_ticket_dialog.dart';
import '../../../model/ticket_item.dart' hide ProductOrder; // Import necessário para ProductOrder

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

  // ⭐️ CORREÇÃO 1: Tipagem do detail corrigida para TicketDetail
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
    // ⭐️ CORREÇÃO 2: Tipar o FutureBuilder com o tipo esperado (TicketDetail)
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
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
              ),
            );
          }

          // Verificação de dados deve ser mais segura agora
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

  // ⭐️ CORREÇÃO 3: Tipagem dos métodos de construção para TicketDetail
  Widget _buildHeader(
      BuildContext context,
      TicketDetail detail, // Tipagem correta
      String formattedDate,
      ) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      color: Theme.of(context).cardColor,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'COMANDA ${detail.number}',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          Text(
            'Aberta em: $formattedDate',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const Divider(height: 30, thickness: 1.5),

          Text(
            'TOTAL DA COMANDA',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'R\$ ${detail.calculatedTotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 40,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ⭐️ CORREÇÃO 4: Tipagem do método e uso do expand() seguro
  Widget _buildItemsHeader(BuildContext context, TicketDetail detail) {
    // ⭐️ CORREÇÃO DO ERRO: O detail agora é TicketDetail, então .orders é seguro.
    // O .expand e .cast garantem o tipo de retorno List<ProductOrder>
    final totalItemCount = detail.orders.expand((order) => order.items).length;

    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        'ITENS PEDIDOS ($totalItemCount):',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  // ⭐️ CORREÇÃO 5: Tipagem do método e uso do expand() seguro para a lista
  Widget _buildItemsList(BuildContext context, TicketDetail detail) {
    // Listamos todos os produtos individuais (ProductOrder)
    final List<ProductOrder> allProducts =
    detail.orders.expand((order) => order.items).toList().cast<ProductOrder>();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: allProducts.length,
        itemBuilder: (context, index) {
          final item = allProducts[index]; // item é ProductOrder

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  '${item.quantity}x', // Propriedades do ProductOrder
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Text(
                item.name, // Propriedades do ProductOrder
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                'R\$ ${item.price.toStringAsFixed(2)} / un.', // Propriedades do ProductOrder
              ),
              trailing: Text(
                'R\$ ${item.total.toStringAsFixed(2)}', // Propriedades do ProductOrder
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ⭐️ CORREÇÃO 6: Tipagem dos métodos de construção para TicketDetail
  Widget _buildActionButtons(BuildContext context, TicketDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSplitButton(context, detail),
          const SizedBox(width: 10),
          _buildPaymentButton(context, detail),
        ],
      ),
    );
  }

  Widget _buildSplitButton(BuildContext context, TicketDetail detail) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _handleSplitTicket(context, detail),
        icon: const Icon(Icons.call_split),
        label: const Text('Dividir'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context, TicketDetail detail) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => onNavigateToPayment(ticket),
        icon: const Icon(Icons.payment),
        label: Text('Pagar (R\$ ${detail.calculatedTotal.toStringAsFixed(2)})'),
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