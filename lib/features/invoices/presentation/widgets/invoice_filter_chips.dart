import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/invoice_provider.dart';

class InvoiceFilterChips extends ConsumerWidget {
  const InvoiceFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(invoiceFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: InvoiceFilterOption.values.map((option) {
          final isSelected = option == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) {
                ref.read(invoiceFilterProvider.notifier).setFilter(option);
              },
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
              ),
              selectedColor: AppColors.primary.withAlpha(25),
              backgroundColor: AppColors.surfaceLight,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 1.5 : 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}
