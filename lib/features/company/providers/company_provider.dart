import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/company_repository.dart';
import '../data/company_repository_impl.dart';
import '../models/company_profile_model.dart';

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return const CompanyRepositoryImpl();
});

final companyProfileProvider = FutureProvider<CompanyProfileModel?>((ref) async {
  final repository = ref.watch(companyRepositoryProvider);
  return repository.getCompanyProfile();
});
