enum InvoiceStatusType { paid, pending, partial }

class InvoiceListModel {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final double amount;
  final String currency;
  final InvoiceStatusType status;
  final String formattedDate;

  const InvoiceListModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    this.currency = 'AED',
    required this.status,
    required this.formattedDate,
  });
}
