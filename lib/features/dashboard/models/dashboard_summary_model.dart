class DashboardSummaryModel {
  final int totalInvoices;
  final int paidInvoices;
  final int pendingInvoices;
  final double totalRevenue;
  final String currency;

  const DashboardSummaryModel({
    required this.totalInvoices,
    required this.paidInvoices,
    required this.pendingInvoices,
    required this.totalRevenue,
    this.currency = 'AED',
  });
}
