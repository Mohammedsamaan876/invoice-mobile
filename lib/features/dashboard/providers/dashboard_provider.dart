import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_mock_data.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_summary_model.dart';
import '../models/recent_invoice_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return const MockDashboardRepository();
});

final dashboardSummaryProvider =
    FutureProvider<DashboardSummaryModel>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getSummary();
});

final recentInvoicesProvider =
    FutureProvider<List<RecentInvoiceModel>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRecentInvoices();
});
