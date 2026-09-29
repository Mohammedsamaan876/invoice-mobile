import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/create_invoice_model.dart';

class InvoiceTotalsSection extends StatelessWidget {
  final CreateInvoiceState state;

  const InvoiceTotalsSection({
    super.key,
    required this.state,
  });

  static String formatCurrency(double amount) {
    return 'AED ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final discountValueStr =
        state.discountValue == state.discountValue.roundToDouble()
            ? state.discountValue.toInt().toString()
            : state.discountValue.toString();

    final String discountLabel;
    final String discountValueFormatted;

    if (state.discountType == DiscountType.percentage && state.discountValue > 0) {
      discountLabel = 'Discount ($discountValueStr%)';
      discountValueFormatted = '- ${formatCurrency(state.discountAmount)}';
    } else if (state.discountType == DiscountType.fixed &&
        state.discountValue > 0) {
      discountLabel = 'Discount';
      discountValueFormatted = '- ${formatCurrency(state.discountAmount)}';
    } else {
      discountLabel = 'Discount';
      discountValueFormatted = formatCurrency(0.0);
    }

    final taxRateStr = state.taxRate == state.taxRate.roundToDouble()
        ? state.taxRate.toInt().toString()
        : state.taxRate.toString();
    final taxLabel = 'Tax ($taxRateStr%)';
    final taxValueFormatted = formatCurrency(state.taxAmount);

    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRow('Subtotal', formatCurrency(state.subtotal)),
          const SizedBox(height: 6),
          _buildRow(
            discountLabel,
            discountValueFormatted,
            isNegative: state.discountAmount > 0,
          ),
          const SizedBox(height: 6),
          _buildRow(taxLabel, taxValueFormatted),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 10),
          _buildRow(
            'Grand Total',
            formatCurrency(state.grandTotal),
            isGrandTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isNegative = false,
    bool isGrandTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 14 : 12,
              fontWeight: isGrandTotal ? FontWeight.w800 : FontWeight.w500,
              color: isGrandTotal
                  ? AppColors.textPrimaryLight
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isGrandTotal ? 15 : 12,
            fontWeight: isGrandTotal ? FontWeight.w800 : FontWeight.w600,
            color: isGrandTotal
                ? AppColors.primary
                : (isNegative ? AppColors.error : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}
