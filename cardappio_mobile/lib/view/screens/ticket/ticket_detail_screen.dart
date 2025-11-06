import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/api_service.dart';
import '../../../model/ticket.dart';
import '../../common/split_ticket_dialog.dart';

// ⚠️ Assumindo que você tem uma classe TicketDetail definida

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

  void _handleSplitTicket(BuildContext context, dynamic detail) async { // Usando dynamic para evitar erro de tipo na função
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
      // ⭐️ CORREÇÃO 1: Fundo do Scaffold branco para integração do Card/Container
      backgroundColor: Theme.of(context).cardColor,

      appBar: AppBar(
        // ⭐️ CORREÇÃO 2: Título simplificado e centralizado
        // title: Text(
        //   'Comanda ${ticket.number} (Mesa ${ticket.number})',
        //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        // ),
        centerTitle: true, // Centraliza o título no AppBar
        elevation: 0, // Remover sombra do AppBar para um visual mais flat
        backgroundColor: Theme.of(context).cardColor, // Fundo branco/claro
      ),
      body: FutureBuilder<dynamic>( // Usando dynamic para TicketDetail
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

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Detalhes da comanda não encontrados.'),
            );
          }

          final detail = snapshot.data!;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
          final formattedDate = dateFormat.format(detail.createdAt);

          return Column(
            children: [
              // ⭐️ CORREÇÃO 3: Header integrado (não flutua sobre o fundo branco)
              _buildHeader(context, detail, formattedDate),

              // ❌ REMOVIDO: Divider desnecessário
              // const Divider(height: 1),

              _buildItemsHeader(context, detail),
              Expanded(child: _buildItemsList(context, detail)),
              _buildActionButtons(context, detail),
            ],
          );
        },
      ),
    );
  }

  // ⭐️ WIDGET _buildHeader AJUSTADO (Removendo BoxShadow e Padding redundante)
  Widget _buildHeader(
      BuildContext context,
      dynamic detail,
      String formattedDate,
      ) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      // ⭐️ CORREÇÃO: Removendo o Card/BoxShadow para integrar o cabeçalho ao Scaffold
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      color: Theme.of(context).cardColor, // Fundo do Card (Branco)

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Título e Número
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

          // 2. Data de Abertura (Sutil)
          Text(
            'Aberta em: $formattedDate',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const Divider(height: 30, thickness: 1.5),

          // 3. Título do Total
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

          // 4. Valor Total (Destaque Principal)
          Text(
            'R\$ ${detail.total.toStringAsFixed(2)}',
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

  // ⭐️ WIDGET AJUSTADO: Título dos Itens (Melhor alinhamento e separação visual)
  Widget _buildItemsHeader(BuildContext context, dynamic detail) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor, // Cor do fundo da lista (provavelmente cinza claro)
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        'ITENS PEDIDOS (${detail.items.length}):',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  // ⭐️ WIDGET AJUSTADO: Lista de Itens (Fundo para a lista)
  Widget _buildItemsList(BuildContext context, dynamic detail) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Fundo da lista cinza claro
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: detail.items.length,
        itemBuilder: (context, index) {
          final item = detail.items[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  '${item.quantity}x',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text('R\$ ${item.unitPrice.toStringAsFixed(2)} / un.'),
              trailing: Text(
                'R\$ ${item.subtotal.toStringAsFixed(2)}',
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

  Widget _buildActionButtons(BuildContext context, dynamic detail) {
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


  Widget _buildSplitButton(BuildContext context, dynamic detail) {
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


  Widget _buildPaymentButton(BuildContext context, dynamic detail) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => onNavigateToPayment(ticket),
        icon: const Icon(Icons.payment),
        label: Text('Pagar (R\$ ${detail.total.toStringAsFixed(2)})'),
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