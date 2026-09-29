import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InvoiceCustomerSection extends StatelessWidget {
  final String? customerName;

  const InvoiceCustomerSection({
    super.key,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = customerName != null && customerName!.trim().isNotEmpty
        ? customerName!.trim()
        : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BILL TO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
