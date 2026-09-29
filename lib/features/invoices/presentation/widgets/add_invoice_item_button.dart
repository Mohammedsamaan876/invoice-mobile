import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddInvoiceItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddInvoiceItemButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          '+ Add Item',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.primary.withAlpha(8),
        ),
      ),
    );
  }
}
