class PixFormData {
  String customerName;
  String customerEmail;
  String customerTaxId; 
  String customerCellphone;

  PixFormData({
    required this.customerName,
    required this.customerEmail,
    required this.customerTaxId,
    required this.customerCellphone,
  });

  bool isValid() {
    return customerName.isNotEmpty &&
        customerEmail.isNotEmpty &&
        customerTaxId.length >= 11 && 
        customerCellphone.length >= 10;
  }
}