import '../models/invoice_list_model.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceListModel>> getInvoices();
  Future<InvoiceListModel?> getInvoiceById(String id);
}
