import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice_preview_model.dart';
import 'create_invoice_provider.dart';

final invoicePreviewProvider = Provider.autoDispose<InvoicePreviewModel>((ref) {
  final invoice = ref.watch(createInvoiceProvider);
  return InvoicePreviewModel(
    invoice: invoice,
  );
});
