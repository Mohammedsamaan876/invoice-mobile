import '../../../core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../models/dashboard_summary_model.dart';
import '../models/recent_invoice_model.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/dashboard_bottom_navigation.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/recent_invoice_card.dart';
import 'widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final recentInvoicesAsync = ref.watch(recentInvoicesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const DashboardHeader(),
      bottomNavigationBar: const DashboardBottomNavigation(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
          children: [
            // 1. Primary Action Button
            _buildCreateInvoiceButton(context),
            const SizedBox(height: 20),

            // 2. Summary Statistics Section
            summaryAsync.when(
              data: (summary) => _buildSummaryCards(summary),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Failed to load metrics: $err'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Recent Invoices Section Header
            _buildRecentInvoicesHeader(context),
            const SizedBox(height: 12),

            // 4. Recent Invoices List
            recentInvoicesAsync.when(
              data: (invoices) => _buildRecentInvoicesList(context, invoices),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Failed to load recent invoices: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateInvoiceButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createInvoice);
        },
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          '+ Create Invoice',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DashboardSummaryModel summary) {
    final revenueText =
        '${summary.currency} ${_formatNumber(summary.totalRevenue)}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Invoices',
                value: summary.totalInvoices.toString(),
                icon: Icons.receipt_long_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBackgroundColor: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Paid',
                value: summary.paidInvoices.toString(),
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF059669),
                iconBackgroundColor: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Pending',
                value: summary.pendingInvoices.toString(),
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xFFD97706),
                iconBackgroundColor: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Revenue',
                value: revenueText,
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFF4F46E5),
                iconBackgroundColor: const Color(0xFFEEF2FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentInvoicesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Recent Invoices',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All invoices view coming soon'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentInvoicesList(
      BuildContext context, List<RecentInvoiceModel> invoices) {
    return Column(
      children: [
        for (int i = 0; i < invoices.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          RecentInvoiceCard(
            invoice: invoices[i],
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invoice ${invoices[i].invoiceNumber} selected'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  String _formatNumber(double amount) {
    final intVal = amount.toInt();
    return intVal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}


