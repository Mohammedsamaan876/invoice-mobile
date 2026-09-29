import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/invoice_preview_model.dart';

// MOCK COMPANY DATA — replace with CompanyRepository later.
class InvoiceCompanySection extends StatelessWidget {
  final CompanyInfo company;

  const InvoiceCompanySection({
    super.key,
    this.company = const CompanyInfo(),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          company.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          company.subtitle,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          company.address,
          style: const TextStyle(
            fontSize: 11,
            height: 1.35,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Phone: ${company.phone}',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Email: ${company.email}',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
