import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InvoiceNotesSection extends StatelessWidget {
  final String initialNotes;
  final ValueChanged<String>? onNotesChanged;
  final bool isPreview;

  const InvoiceNotesSection({
    super.key,
    required this.initialNotes,
    this.onNotesChanged,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPreview) {
      if (initialNotes.trim().isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOTES & PAYMENT TERMS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            initialNotes,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      );
    }

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
            'Notes & Payment Terms',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: initialNotes,
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add notes or payment terms...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
              contentPadding: const EdgeInsets.all(12),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: onNotesChanged,
          ),
        ],
      ),
    );
  }
}
