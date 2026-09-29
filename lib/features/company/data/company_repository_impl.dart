import 'company_repository.dart';
import '../models/company_profile_model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  const CompanyRepositoryImpl();

  @override
  Future<CompanyProfileModel?> getCompanyProfile() async {
    return null;
  }

  @override
  Future<CompanyProfileModel> saveCompanyProfile(CompanyProfileModel profile) async {
    return profile;
  }
}
