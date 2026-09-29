import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import '../../providers/invoice_provider.dart';
import '../widgets/invoice_filter_chips.dart';
import '../widgets/invoice_list_card.dart';
import '../widgets/invoice_list_header.dart';
import '../widgets/invoice_search_bar.dart';

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredInvoicesAsync = ref.watch(filteredInvoicesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const InvoiceListHeader(),
      bottomNavigationBar: const DashboardBottomNavigation(selectedIndex: 1),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Controls: Search Bar and Horizontal Filter Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
              child: Column(
                children: const [
                  InvoiceSearchBar(),
                  SizedBox(height: 12),
                  InvoiceFilterChips(),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Invoices List or Empty State
            Expanded(
              child: filteredInvoicesAsync.when(
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
                    itemCount: invoices.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return InvoiceListCard(
                        invoice: invoice,
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invoice details coming soon'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Failed to load invoices: $err'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: AppColors.textSecondaryLight,
            ),
            SizedBox(height: 16),
            Text(
              'No invoices found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Try changing your search or filter.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
