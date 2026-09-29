import '../models/company_profile_model.dart';

abstract class CompanyRepository {
  Future<CompanyProfileModel?> getCompanyProfile();
  Future<CompanyProfileModel> saveCompanyProfile(CompanyProfileModel profile);
}
