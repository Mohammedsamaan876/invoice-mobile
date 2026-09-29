import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InvoicePreviewHeader extends StatelessWidget {
  const InvoicePreviewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Invoice Preview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Review your invoice before generating the PDF',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
