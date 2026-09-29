import 'invoice_repository.dart';
import '../models/invoice_list_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  const InvoiceRepositoryImpl();

  @override
  Future<List<InvoiceListModel>> getInvoices() async {
    return [];
  }

  @override
  Future<InvoiceListModel?> getInvoiceById(String id) async {
    return null;
  }
}
