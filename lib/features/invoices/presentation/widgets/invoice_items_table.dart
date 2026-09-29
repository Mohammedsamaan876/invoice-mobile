import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/invoice_item_model.dart';

class InvoiceItemsTable extends StatelessWidget {
  final List<InvoiceItemModel> items;

  const InvoiceItemsTable({
    super.key,
    required this.items,
  });

  static String formatCurrency(double amount) {
    return 'AED ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1),
              bottom: BorderSide(color: AppColors.borderLight, width: 1.5),
            ),
            color: Color(0xFFF8FAFC),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  'Qty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              SizedBox(
                width: 82,
                child: Text(
                  'Rate',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              SizedBox(
                width: 88,
                child: Text(
                  'Amount',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Item Rows
        ...items.map((item) {
          final amount = item.quantity * item.unitPrice;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    item.description.trim().isNotEmpty
                        ? item.description
                        : 'Item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 82,
                  child: Text(
                    formatCurrency(item.unitPrice),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 88,
                  child: Text(
                    formatCurrency(amount),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
