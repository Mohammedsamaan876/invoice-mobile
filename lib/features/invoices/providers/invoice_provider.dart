import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/invoice_mock_data.dart';
import '../data/invoice_repository.dart';
import '../models/invoice_list_model.dart';

enum InvoiceFilterOption {
  all('All'),
  paid('Paid'),
  pending('Pending'),
  partial('Partial');

  final String label;
  const InvoiceFilterOption(this.label);
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return const MockInvoiceRepository();
});

final allInvoicesProvider = FutureProvider<List<InvoiceListModel>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getInvoices();
});

class InvoiceSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearchQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final invoiceSearchProvider =
    NotifierProvider<InvoiceSearchNotifier, String>(InvoiceSearchNotifier.new);

class InvoiceFilterNotifier extends Notifier<InvoiceFilterOption> {
  @override
  InvoiceFilterOption build() => InvoiceFilterOption.all;

  void setFilter(InvoiceFilterOption filter) {
    state = filter;
  }
}

final invoiceFilterProvider =
    NotifierProvider<InvoiceFilterNotifier, InvoiceFilterOption>(
        InvoiceFilterNotifier.new);

final filteredInvoicesProvider =
    Provider<AsyncValue<List<InvoiceListModel>>>((ref) {
  final invoicesAsync = ref.watch(allInvoicesProvider);
  final searchQuery = ref.watch(invoiceSearchProvider).trim().toLowerCase();
  final currentFilter = ref.watch(invoiceFilterProvider);

  return invoicesAsync.whenData((invoices) {
    return invoices.where((invoice) {
      // 1. Filter by status
      final matchesFilter = switch (currentFilter) {
        InvoiceFilterOption.all => true,
        InvoiceFilterOption.paid => invoice.status == InvoiceStatusType.paid,
        InvoiceFilterOption.pending =>
          invoice.status == InvoiceStatusType.pending,
        InvoiceFilterOption.partial =>
          invoice.status == InvoiceStatusType.partial,
      };

      if (!matchesFilter) return false;

      // 2. Filter by search query (invoice number or customer name)
      if (searchQuery.isEmpty) return true;
      final matchesNumber =
          invoice.invoiceNumber.toLowerCase().contains(searchQuery);
      final matchesCustomer =
          invoice.customerName.toLowerCase().contains(searchQuery);

      return matchesNumber || matchesCustomer;
    }).toList();
  });
});
