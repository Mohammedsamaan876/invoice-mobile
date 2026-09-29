import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../customers/models/customer_model.dart';
import '../../customers/providers/customer_provider.dart';
import '../models/create_invoice_model.dart';
import '../models/invoice_item_model.dart';

class CreateInvoiceNotifier extends Notifier<CreateInvoiceState> {
  int _itemCounter = 1;

  @override
  CreateInvoiceState build() {
    return CreateInvoiceState(
      invoiceNumber: 'INV-006',
      customerInfo: null,
      invoiceDate: DateTime(2026, 9, 26),
      dueDate: DateTime(2026, 10, 10),
      items: const [
        InvoiceItemModel(
          id: 'item_1',
          description: 'Website Development',
          quantity: 1,
          unitPrice: 5000.0,
        ),
      ],
      discountType: DiscountType.none,
      discountValue: 0.0,
      taxRate: 5.0,
      notes: 'Payment due within 14 days.',
    );
  }

  void setCustomer(String? customer) {
    if (customer == null || customer.trim().isEmpty) {
      state = state.copyWith(clearCustomer: true);
      return;
    }
    if (state.customerInfo != null &&
        state.customerInfo!.name.toLowerCase() == customer.trim().toLowerCase()) {
      return;
    }
    final savedCustomers = ref.read(customerListNotifierProvider);
    final match = savedCustomers
        .where((c) => c.name.toLowerCase() == customer.trim().toLowerCase())
        .firstOrNull;
    if (match != null) {
      state = state.copyWith(customerInfo: match);
    } else {
      state = state.copyWith(
        customerInfo: CustomerModel(
          id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
          name: customer.trim(),
          isSaved: false,
        ),
      );
    }
  }

  void setCustomerInfo(CustomerModel customer) {
    state = state.copyWith(customerInfo: customer);
  }

  void updateInvoiceCustomer(CustomerModel customer) {
    state = state.copyWith(customerInfo: customer);
  }

  void clearCustomer() {
    state = state.copyWith(clearCustomer: true);
  }

  void setInvoiceDate(DateTime date) {
    state = state.copyWith(invoiceDate: date);
  }

  void setDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void addItem({
    String description = '',
    int quantity = 1,
    double unitPrice = 0.0,
  }) {
    _itemCounter++;
    final newItem = InvoiceItemModel(
      id: 'item_$_itemCounter',
      description: description,
      quantity: quantity > 0 ? quantity : 1,
      unitPrice: unitPrice >= 0 ? unitPrice : 0.0,
    );
    state = state.copyWith(items: [...state.items, newItem]);
  }

  void removeItem(String id) {
    if (state.items.length <= 1) return;
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  void updateItem(
    String id, {
    String? description,
    int? quantity,
    double? unitPrice,
  }) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(
            description: description,
            quantity:
                quantity != null && quantity > 0 ? quantity : item.quantity,
            unitPrice:
                unitPrice != null && unitPrice >= 0 ? unitPrice : item.unitPrice,
          );
        }
        return item;
      }).toList(),
    );
  }

  void incrementQuantity(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(quantity: item.quantity + 1);
        }
        return item;
      }).toList(),
    );
  }

  void decrementQuantity(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id && item.quantity > 1) {
          return item.copyWith(quantity: item.quantity - 1);
        }
        return item;
      }).toList(),
    );
  }

  void setDiscountType(DiscountType type) {
    state = state.copyWith(discountType: type);
  }

  void setDiscountValue(double value) {
    state = state.copyWith(discountValue: value >= 0 ? value : 0.0);
  }

  void updateTaxRate(double rate) {
    if (rate >= 0 && rate <= 100) {
      state = state.copyWith(taxRate: rate);
    }
  }

  void setTaxRate(double rate) => updateTaxRate(rate);

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  String? validate() {
    if (state.customer == null || state.customer!.trim().isEmpty) {
      return 'Please select a customer';
    }
    if (state.items.isEmpty) {
      return 'Please add at least one item';
    }
    for (final item in state.items) {
      if (item.description.trim().isEmpty) {
        return 'Please enter a product';
      }
      if (item.quantity <= 0) {
        return 'Quantity must be greater than 0';
      }
      if (item.unitPrice < 0) {
        return 'Please enter a valid price';
      }
    }
    if (state.dueDate.isBefore(state.invoiceDate)) {
      return 'Due date cannot be before invoice date';
    }
    if (state.discountType == DiscountType.percentage &&
        (state.discountValue < 0 || state.discountValue > 100)) {
      return 'Please enter a valid discount percentage (0-100)';
    }
    if (state.discountType == DiscountType.fixed && state.discountValue < 0) {
      return 'Please enter a valid discount amount';
    }
    if (state.taxRate < 0 || state.taxRate > 100) {
      return 'Tax rate must be between 0% and 100%.';
    }
    return null;
  }

  void reset() {
    _itemCounter = 1;
    state = build();
  }
}

final createInvoiceProvider =
    NotifierProvider.autoDispose<CreateInvoiceNotifier, CreateInvoiceState>(
  CreateInvoiceNotifier.new,
);
