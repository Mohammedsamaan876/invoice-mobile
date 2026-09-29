enum DashboardInvoiceStatus { paid, pending, partial }

class RecentInvoiceModel {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final double amount;
  final String currency;
  final DashboardInvoiceStatus status;
  final String formattedDate;

  const RecentInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    this.currency = 'AED',
    required this.status,
    required this.formattedDate,
  });
}
