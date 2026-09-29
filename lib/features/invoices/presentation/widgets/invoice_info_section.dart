import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InvoiceInfoSection extends StatelessWidget {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;

  const InvoiceInfoSection({
    super.key,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
  });

  static String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'INVOICE',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Invoice Number:', invoiceNumber, isHighlighted: true),
        const SizedBox(height: 4),
        _buildInfoRow('Invoice Date:', formatDate(invoiceDate)),
        const SizedBox(height: 4),
        _buildInfoRow('Due Date:', formatDate(dueDate)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 14 : 12,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
