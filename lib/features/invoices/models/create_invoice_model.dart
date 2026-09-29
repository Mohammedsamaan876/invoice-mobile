import '../../customers/models/customer_model.dart';
import 'invoice_item_model.dart';

enum DiscountType {
  none('None'),
  percentage('Percentage (%)'),
  fixed('Fixed (AED)');

  final String label;
  const DiscountType(this.label);
}

class CreateInvoiceState {
  final String invoiceNumber;
  final CustomerModel? customerInfo;
  final String? _legacyCustomer;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<InvoiceItemModel> items;
  final DiscountType discountType;
  final double discountValue;
  final double taxRate;
  final String notes;

  const CreateInvoiceState({
    this.invoiceNumber = 'INV-006',
    this.customerInfo,
    String? customer,
    required this.invoiceDate,
    required this.dueDate,
    this.items = const [],
    this.discountType = DiscountType.none,
    this.discountValue = 0.0,
    this.taxRate = 5.0,
    this.notes = 'Payment due within 14 days.',
  }) : _legacyCustomer = customer;

  String? get customer => customerInfo?.name ?? _legacyCustomer;

  // 1. itemTotal = quantity x unitPrice
  // Subtotal = sum(all itemTotal)
  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));

  // 2. Discount calculation
  double get discountAmount {
    if (discountType == DiscountType.none || discountValue <= 0) return 0.0;
    if (discountType == DiscountType.percentage) {
      final pct = discountValue.clamp(0.0, 100.0);
      return (subtotal * pct) / 100.0;
    } else {
      // Fixed amount discount cannot exceed subtotal
      return discountValue.clamp(0.0, subtotal);
    }
  }

  // 3. Taxable amount = subtotal - discountAmount
  double get taxableAmount =>
      (subtotal - discountAmount).clamp(0.0, double.infinity);

  // 4. Tax amount = taxableAmount x taxRate / 100
  double get taxAmount {
    if (taxRate <= 0 || taxRate > 100) return 0.0;
    return (taxableAmount * taxRate) / 100.0;
  }

  // 5. Grand Total = taxableAmount + taxAmount
  double get grandTotal => taxableAmount + taxAmount;

  CreateInvoiceState copyWith({
    String? invoiceNumber,
    CustomerModel? customerInfo,
    String? customer,
    bool clearCustomer = false,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<InvoiceItemModel>? items,
    DiscountType? discountType,
    double? discountValue,
    double? taxRate,
    String? notes,
  }) {
    CustomerModel? newCustomerInfo;
    String? newLegacyCustomer;

    if (clearCustomer) {
      newCustomerInfo = null;
      newLegacyCustomer = null;
    } else {
      if (customerInfo != null) {
        newCustomerInfo = customerInfo;
        newLegacyCustomer = customerInfo.name;
      } else if (customer != null) {
        newCustomerInfo = this.customerInfo?.copyWith(name: customer);
        newLegacyCustomer = customer;
      } else {
        newCustomerInfo = this.customerInfo;
        newLegacyCustomer = _legacyCustomer;
      }
    }

    return CreateInvoiceState(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerInfo: newCustomerInfo,
      customer: newLegacyCustomer,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      taxRate: taxRate ?? this.taxRate,
      notes: notes ?? this.notes,
    );
  }
}
