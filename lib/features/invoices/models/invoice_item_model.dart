class InvoiceItemModel {
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

  InvoiceItemModel copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
