import 'dashboard_repository.dart';
import '../models/dashboard_summary_model.dart';
import '../models/recent_invoice_model.dart';

/// Mock data repository for the Dashboard UI.
/// This mock data source simulates dashboard metrics and recent invoices.
/// Easily replaceable with Supabase implementation in future phases.
class MockDashboardRepository implements DashboardRepository {
  const MockDashboardRepository();

  @override
  Future<DashboardSummaryModel> getSummary() async {
    return const DashboardSummaryModel(
      totalInvoices: 124,
      paidInvoices: 98,
      pendingInvoices: 26,
      totalRevenue: 48250.0,
      currency: 'AED',
    );
  }

  @override
  Future<List<RecentInvoiceModel>> getRecentInvoices() async {
    return const [
      RecentInvoiceModel(
        id: '1',
        invoiceNumber: 'INV-001',
        customerName: 'ZAHURUDDIN',
        amount: 38100.0,
        currency: 'AED',
        status: DashboardInvoiceStatus.paid,
        formattedDate: '24 Sep 2026',
      ),
      RecentInvoiceModel(
        id: '2',
        invoiceNumber: 'INV-002',
        customerName: 'ABC Trading',
        amount: 12500.0,
        currency: 'AED',
        status: DashboardInvoiceStatus.pending,
        formattedDate: '22 Sep 2026',
      ),
      RecentInvoiceModel(
        id: '3',
        invoiceNumber: 'INV-003',
        customerName: 'XYZ LLC',
        amount: 8200.0,
        currency: 'AED',
        status: DashboardInvoiceStatus.paid,
        formattedDate: '20 Sep 2026',
      ),
      RecentInvoiceModel(
        id: '4',
        invoiceNumber: 'INV-004',
        customerName: 'Global Electronics',
        amount: 5600.0,
        currency: 'AED',
        status: DashboardInvoiceStatus.pending,
        formattedDate: '18 Sep 2026',
      ),
      RecentInvoiceModel(
        id: '5',
        invoiceNumber: 'INV-005',
        customerName: 'Tech Solutions',
        amount: 14300.0,
        currency: 'AED',
        status: DashboardInvoiceStatus.paid,
        formattedDate: '15 Sep 2026',
      ),
    ];
  }
}
