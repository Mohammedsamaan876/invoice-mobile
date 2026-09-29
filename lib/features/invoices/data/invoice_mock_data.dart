// MOCK DATA — replace with Supabase repository later.
import 'invoice_repository.dart';
import '../models/invoice_list_model.dart';

class MockProductItem {
  final String title;
  final double unitPrice;

  const MockProductItem({
    required this.title,
    required this.unitPrice,
  });
}

class MockInvoiceRepository implements InvoiceRepository {
  const MockInvoiceRepository();

  static const List<String> mockCustomers = [
    'ZAHURUDDIN',
    'ABC Trading',
    'XYZ LLC',
    'Global Electronics',
    'Tech Solutions',
  ];

  static const List<MockProductItem> mockProducts = [
    MockProductItem(title: 'Website Development', unitPrice: 5000.0),
    MockProductItem(title: 'Mobile App Development', unitPrice: 8000.0),
    MockProductItem(title: 'UI/UX Design', unitPrice: 2500.0),
    MockProductItem(title: 'Maintenance', unitPrice: 1500.0),
    MockProductItem(title: 'Consulting', unitPrice: 3000.0),
  ];

  static const List<InvoiceListModel> _mockInvoices = [
    InvoiceListModel(
      id: '1',
      invoiceNumber: 'INV-001',
      customerName: 'ZAHURUDDIN',
      amount: 38100.0,
      currency: 'AED',
      status: InvoiceStatusType.paid,
      formattedDate: '24 Sep 2026',
    ),
    InvoiceListModel(
      id: '2',
      invoiceNumber: 'INV-002',
      customerName: 'ABC Trading',
      amount: 12500.0,
      currency: 'AED',
      status: InvoiceStatusType.pending,
      formattedDate: '22 Sep 2026',
    ),
    InvoiceListModel(
      id: '3',
      invoiceNumber: 'INV-003',
      customerName: 'XYZ LLC',
      amount: 8200.0,
      currency: 'AED',
      status: InvoiceStatusType.paid,
      formattedDate: '20 Sep 2026',
    ),
    InvoiceListModel(
      id: '4',
      invoiceNumber: 'INV-004',
      customerName: 'Global Electronics',
      amount: 5600.0,
      currency: 'AED',
      status: InvoiceStatusType.pending,
      formattedDate: '18 Sep 2026',
    ),
    InvoiceListModel(
      id: '5',
      invoiceNumber: 'INV-005',
      customerName: 'Tech Solutions',
      amount: 14300.0,
      currency: 'AED',
      status: InvoiceStatusType.paid,
      formattedDate: '15 Sep 2026',
    ),
    InvoiceListModel(
      id: '6',
      invoiceNumber: 'INV-006',
      customerName: 'Apex Logistics',
      amount: 21400.0,
      currency: 'AED',
      status: InvoiceStatusType.partial,
      formattedDate: '12 Sep 2026',
    ),
    InvoiceListModel(
      id: '7',
      invoiceNumber: 'INV-007',
      customerName: 'Prime Retailers',
      amount: 9750.0,
      currency: 'AED',
      status: InvoiceStatusType.paid,
      formattedDate: '10 Sep 2026',
    ),
    InvoiceListModel(
      id: '8',
      invoiceNumber: 'INV-008',
      customerName: 'Desert Oasis Hospitality',
      amount: 16800.0,
      currency: 'AED',
      status: InvoiceStatusType.pending,
      formattedDate: '07 Sep 2026',
    ),
    InvoiceListModel(
      id: '9',
      invoiceNumber: 'INV-009',
      customerName: 'Gulf Horizon Consulting',
      amount: 31200.0,
      currency: 'AED',
      status: InvoiceStatusType.partial,
      formattedDate: '04 Sep 2026',
    ),
    InvoiceListModel(
      id: '10',
      invoiceNumber: 'INV-010',
      customerName: 'Emirates Media Group',
      amount: 7900.0,
      currency: 'AED',
      status: InvoiceStatusType.paid,
      formattedDate: '01 Sep 2026',
    ),
  ];

  @override
  Future<List<InvoiceListModel>> getInvoices() async {
    return _mockInvoices;
  }

  @override
  Future<InvoiceListModel?> getInvoiceById(String id) async {
    try {
      return _mockInvoices.firstWhere((inv) => inv.id == id);
    } catch (_) {
      return null;
    }
  }
}
