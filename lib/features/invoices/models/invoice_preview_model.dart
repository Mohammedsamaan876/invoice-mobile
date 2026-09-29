import 'create_invoice_model.dart';

// MOCK COMPANY DATA — replace with CompanyRepository later.
class CompanyInfo {
  final String name;
  final String subtitle;
  final String address;
  final String phone;
  final String email;

  const CompanyInfo({
    this.name = 'YOUR COMPANY',
    this.subtitle = 'Professional Invoice',
    this.address = '123 Business Street\nDubai, UAE',
    this.phone = '+971 50 000 0000',
    this.email = 'hello@yourcompany.com',
  });
}

class InvoicePreviewModel {
  final CompanyInfo company;
  final CreateInvoiceState invoice;

  const InvoicePreviewModel({
    this.company = const CompanyInfo(),
    required this.invoice,
  });
}
