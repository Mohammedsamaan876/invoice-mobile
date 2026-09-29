import '../models/customer_model.dart';

abstract class CustomerRepository {
  List<CustomerModel> getInitialCustomers();
  Future<List<CustomerModel>> getCustomers();
  Future<CustomerModel?> getCustomerById(String id);
  Future<CustomerModel> createCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}
