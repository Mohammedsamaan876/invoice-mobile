import '../../../data/models/base_model.dart';

enum InvoiceStatus { draft, sent, paid, overdue, cancelled }

class InvoiceItemModel extends BaseModel {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;

  const InvoiceItemModel({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

class InvoiceModel extends BaseModel {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItemModel> items;
  final double discount;
  final double taxRate;
  final InvoiceStatus status;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.issueDate,
    required this.dueDate,
    this.items = const [],
    this.discount = 0.0,
    this.taxRate = 0.0,
    this.status = InvoiceStatus.draft,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      customerId: json['customer_id'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'discount': discount,
      'tax_rate': taxRate,
      'status': status.name,
    };
  }
}
