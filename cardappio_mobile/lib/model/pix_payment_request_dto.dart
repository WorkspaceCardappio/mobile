
import 'pix_form_data.dart'; 

class PixPaymentRequestDTO {
  final String ticketId; 
  final String description;
  final double amount;

  final PixFormData customerData; 

  PixPaymentRequestDTO({
    required this.ticketId,
    required this.description,
    required this.amount,
    required this.customerData,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId, 
      'description': description,
      'amount': amount,
      
      'customerName': customerData.customerName,
      'customerEmail': customerData.customerEmail,
      'customerTaxId': customerData.customerTaxId,
      'customerCellphone': customerData.customerCellphone,
    };
  }
}