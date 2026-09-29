import '../models/dashboard_summary_model.dart';
import '../models/recent_invoice_model.dart';

abstract class DashboardRepository {
  Future<DashboardSummaryModel> getSummary();
  Future<List<RecentInvoiceModel>> getRecentInvoices();
}
