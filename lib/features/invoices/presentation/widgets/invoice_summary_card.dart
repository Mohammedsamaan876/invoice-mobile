import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/create_invoice_model.dart';

class InvoiceSummaryCard extends StatelessWidget {
  final CreateInvoiceState state;

  const InvoiceSummaryCard({
    super.key,
    required this.state,
  });

  String _formatCurrency(double amount) {
    return 'AED ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final discountValueStr = state.discountValue == state.discountValue.roundToDouble()
        ? state.discountValue.toInt().toString()
        : state.discountValue.toString();
    final discountLabel = state.discountType == DiscountType.percentage &&
            state.discountValue > 0
        ? 'Discount ($discountValueStr%)'
        : 'Discount';

    final taxRateStr = state.taxRate == state.taxRate.roundToDouble()
        ? state.taxRate.toInt().toString()
        : state.taxRate.toString();
    final taxLabel = state.taxRate >= 0 && state.taxRate <= 100
        ? 'Tax ($taxRateStr%)'
        : 'Tax';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 14),

          // Subtotal
          _buildRow(
            label: 'Subtotal',
            value: _formatCurrency(state.subtotal),
            isBold: false,
          ),
          const SizedBox(height: 8),

          // Discount
          _buildRow(
            label: discountLabel,
            value: state.discountAmount > 0
                ? '- ${_formatCurrency(state.discountAmount)}'
                : _formatCurrency(0.0),
            isBold: false,
            valueColor: state.discountAmount > 0 ? AppColors.error : null,
          ),
          const SizedBox(height: 8),

          // Tax
          _buildRow(
            label: taxLabel,
            value: _formatCurrency(state.taxAmount),
            isBold: false,
          ),
          const SizedBox(height: 12),

          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 12),

          // Grand Total
          _buildRow(
            label: 'Grand Total',
            value: _formatCurrency(state.grandTotal),
            isBold: true,
            fontSize: 17,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required bool isBold,
    double fontSize = 14,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold
                  ? AppColors.textPrimaryLight
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimaryLight,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
