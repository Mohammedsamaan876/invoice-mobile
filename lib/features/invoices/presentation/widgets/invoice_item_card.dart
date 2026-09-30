import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/invoice_item_model.dart';
import 'product_picker_sheet.dart';

class InvoiceItemCard extends StatelessWidget {
  final int index;
  final InvoiceItemModel item;
  final bool canDelete;
  final VoidCallback onDelete;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onUnitPriceChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const InvoiceItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.canDelete,
    required this.onDelete,
    required this.onDescriptionChanged,
    required this.onQuantityChanged,
    required this.onUnitPriceChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  void _showProductPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => ProductPickerSheet(
        selectedTitle: item.description,
        onProductSelected: (product) {
          onDescriptionChanged(product.name);
          onUnitPriceChanged(product.unitPrice);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Item # and Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item #${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: 'Delete item',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Product / Description selector or input
          InkWell(
            onTap: () => _showProductPicker(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.description.isNotEmpty
                          ? item.description
                          : 'Select Product / Service',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.description.isNotEmpty
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: item.description.isNotEmpty
                            ? AppColors.textPrimaryLight
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quantity Controls & Unit Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quantity (- 1 +)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 18),
                            tooltip: 'Decrease',
                            padding: EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(minWidth: 32, minHeight: 32),
                            visualDensity: VisualDensity.compact,
                            onPressed: item.quantity > 1 ? onDecrement : null,
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 18),
                            tooltip: 'Increase',
                            padding: EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(minWidth: 32, minHeight: 32),
                            visualDensity: VisualDensity.compact,
                            onPressed: onIncrement,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Unit Price
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit Price (AED)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _UnitPriceInputField(
                      initialPrice: item.unitPrice,
                      onPriceChanged: onUnitPriceChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item subtotal
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: AED ${item.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitPriceInputField extends StatefulWidget {
  final double initialPrice;
  final ValueChanged<double> onPriceChanged;

  const _UnitPriceInputField({
    required this.initialPrice,
    required this.onPriceChanged,
  });

  @override
  State<_UnitPriceInputField> createState() => _UnitPriceInputFieldState();
}

class _UnitPriceInputFieldState extends State<_UnitPriceInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPrice > 0
          ? widget.initialPrice.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant _UnitPriceInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPrice != widget.initialPrice) {
      final currentParsed = double.tryParse(_controller.text) ?? 0.0;
      if (currentParsed != widget.initialPrice) {
        _controller.text = widget.initialPrice > 0
            ? widget.initialPrice.toStringAsFixed(2)
            : '';
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixText: 'AED ',
          prefixStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
          ),
          hintText: '0.00',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: (val) {
          final parsed = double.tryParse(val.trim());
          if (parsed != null && parsed >= 0) {
            widget.onPriceChanged(parsed);
          } else if (val.trim().isEmpty) {
            widget.onPriceChanged(0.0);
          }
        },
      ),
    );
  }
}
