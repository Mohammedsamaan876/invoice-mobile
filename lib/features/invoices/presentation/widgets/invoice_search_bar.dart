import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/invoice_provider.dart';

class InvoiceSearchBar extends ConsumerStatefulWidget {
  const InvoiceSearchBar({super.key});

  @override
  ConsumerState<InvoiceSearchBar> createState() => _InvoiceSearchBarState();
}

class _InvoiceSearchBarState extends ConsumerState<InvoiceSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(invoiceSearchProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(invoiceSearchProvider, (_, next) {
      if (_controller.text != next) {
        _controller.text = next;
      }
    });

    final hasQuery = ref.watch(invoiceSearchProvider).isNotEmpty;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          ref.read(invoiceSearchProvider.notifier).setSearchQuery(value);
        },
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: 'Search invoices...',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondaryLight,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: AppColors.textSecondaryLight,
                  ),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _controller.clear();
                    ref.read(invoiceSearchProvider.notifier).clear();
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
