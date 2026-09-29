import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/customer_repository.dart';
import '../data/customer_repository_impl.dart';
import '../models/customer_model.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl();
});

class CustomerListNotifier extends Notifier<List<CustomerModel>> {
  @override
  List<CustomerModel> build() {
    final repo = ref.watch(customerRepositoryProvider);

    ref.listen(currentUserProvider, (prev, next) {
      if (prev?.id != next?.id) {
        loadCustomers();
      }
    });

    return repo.getInitialCustomers();
  }

  Future<List<CustomerModel>> loadCustomers() async {
    final repo = ref.read(customerRepositoryProvider);
    try {
      final customers = await repo.getCustomers();
      state = customers;
      return customers;
    } catch (_) {
      return state;
    }
  }

  void setCustomers(List<CustomerModel> customers) {
    state = customers;
  }

  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    final repo = ref.read(customerRepositoryProvider);
    final created = await repo.createCustomer(customer);
    state = [...state.where((c) => c.id != created.id), created];
    ref.invalidate(customersListProvider);
    return created;
  }

  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    final repo = ref.read(customerRepositoryProvider);
    final updated = await repo.updateCustomer(customer);
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
    ref.invalidate(customersListProvider);
    return updated;
  }

  Future<void> deleteCustomer(String id) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.deleteCustomer(id);
    state = state.where((c) => c.id != id).toList();
    ref.invalidate(customersListProvider);
  }
}

final customerListNotifierProvider =
    NotifierProvider<CustomerListNotifier, List<CustomerModel>>(
  CustomerListNotifier.new,
);

final customersListProvider = FutureProvider<List<CustomerModel>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  final customers = await repo.getCustomers();
  ref.read(customerListNotifierProvider.notifier).setCustomers(customers);
  return customers;
});
