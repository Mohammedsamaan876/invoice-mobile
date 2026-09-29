import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/customer_model.dart';
import 'customer_repository.dart';

class CustomerException implements Exception {
  final String message;
  final dynamic originalError;

  const CustomerException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class CustomerRepositoryImpl implements CustomerRepository {
  final SupabaseClient? _client;
  final List<CustomerModel> _memoryCustomers = [];
  bool _hasFetchedFromSupabase = false;

  CustomerRepositoryImpl({
    SupabaseClient? client,
    List<CustomerModel>? initialCustomers,
  }) : _client = client ?? SupabaseConfig.client {
    if (initialCustomers != null) {
      _memoryCustomers.addAll(initialCustomers);
    } else {
      _memoryCustomers.addAll(_defaultMockCustomers);
    }
  }

  static const List<CustomerModel> _defaultMockCustomers = [
    CustomerModel(
      id: 'cust_1',
      name: 'ZAHURUDDIN',
      companyName: 'Zahur General Trading LLC',
      phone: '+971 50 123 4567',
      email: 'zahur@example.com',
      address: 'Deira, Al Sabkha Road',
      city: 'Dubai',
      country: 'United Arab Emirates',
      taxNumber: '100234567800003',
      isSaved: true,
    ),
    CustomerModel(
      id: 'cust_2',
      name: 'ABC Trading',
      companyName: 'ABC Trading FZE',
      phone: '+971 55 987 6543',
      email: 'contact@abctrading.ae',
      address: 'Business Bay, Tower 1',
      city: 'Dubai',
      country: 'United Arab Emirates',
      taxNumber: '100987654300003',
      isSaved: true,
    ),
    CustomerModel(
      id: 'cust_3',
      name: 'XYZ LLC',
      companyName: 'XYZ Contracting LLC',
      phone: '+971 4 321 0000',
      email: 'info@xyzllc.com',
      address: 'Downtown Dubai',
      city: 'Dubai',
      country: 'United Arab Emirates',
      taxNumber: '100456789000003',
      isSaved: true,
    ),
    CustomerModel(
      id: 'cust_4',
      name: 'Global Electronics',
      companyName: 'Global Electronics ME',
      phone: '+971 4 456 7890',
      email: 'sales@globalelec.com',
      address: 'Al Barsha 1',
      city: 'Dubai',
      country: 'United Arab Emirates',
      taxNumber: '100654321000003',
      isSaved: true,
    ),
    CustomerModel(
      id: 'cust_5',
      name: 'Tech Solutions',
      companyName: 'Tech Solutions ME',
      phone: '+971 52 345 6789',
      email: 'support@techsolutions.ae',
      address: 'Dubai Internet City',
      city: 'Dubai',
      country: 'United Arab Emirates',
      taxNumber: '100789123000003',
      isSaved: true,
    ),
  ];

  @override
  List<CustomerModel> getInitialCustomers() =>
      List.unmodifiable(_memoryCustomers);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (sb == null || user == null) {
      return List.unmodifiable(_memoryCustomers);
    }

    try {
      final response = await sb
          .from('customers')
          .select()
          .eq('user_id', user.id)
          .order('name', ascending: true);

      final List<dynamic> rows = response as List<dynamic>;
      final customers = rows
          .map((row) =>
              CustomerModel.fromSupabase(Map<String, dynamic>.from(row as Map)))
          .toList();

      _memoryCustomers.clear();
      _memoryCustomers.addAll(customers);
      _hasFetchedFromSupabase = true;
      return List.unmodifiable(_memoryCustomers);
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      if (!_hasFetchedFromSupabase && _memoryCustomers.isNotEmpty) {
        return List.unmodifiable(_memoryCustomers);
      }
      throw _mapError(e);
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (sb == null || user == null) {
      try {
        return _memoryCustomers.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    }

    try {
      final response = await sb
          .from('customers')
          .select()
          .eq('id', id)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        return CustomerModel.fromSupabase(
            Map<String, dynamic>.from(response as Map));
      }
      return null;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (sb == null) {
      final existingIndex =
          _memoryCustomers.indexWhere((c) => c.id == customer.id);
      if (existingIndex >= 0) {
        _memoryCustomers[existingIndex] = customer;
      } else {
        _memoryCustomers.add(customer);
      }
      return customer;
    }

    if (user == null) {
      throw const CustomerException('Please sign in to save customers to the cloud.');
    }

    try {
      final payload = customer.toSupabaseMap(userId: user.id);
      final response = await sb
          .from('customers')
          .insert(payload)
          .select()
          .single();

      final created = CustomerModel.fromSupabase(
          Map<String, dynamic>.from(response as Map));
      _memoryCustomers.removeWhere((c) => c.id == created.id);
      _memoryCustomers.add(created);
      return created;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (sb == null) {
      final index = _memoryCustomers.indexWhere((c) => c.id == customer.id);
      if (index >= 0) {
        _memoryCustomers[index] = customer;
      } else {
        _memoryCustomers.add(customer);
      }
      return customer;
    }

    if (user == null) {
      throw const CustomerException('Please sign in to update customers in the cloud.');
    }

    try {
      final payload = customer.toSupabaseMap(userId: user.id);
      final response = await sb
          .from('customers')
          .update(payload)
          .eq('id', customer.id)
          .eq('user_id', user.id)
          .select()
          .single();

      final updated = CustomerModel.fromSupabase(
          Map<String, dynamic>.from(response as Map));
      final idx = _memoryCustomers.indexWhere((c) => c.id == updated.id);
      if (idx >= 0) {
        _memoryCustomers[idx] = updated;
      } else {
        _memoryCustomers.add(updated);
      }
      return updated;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (sb == null) {
      _memoryCustomers.removeWhere((c) => c.id == id);
      return;
    }

    if (user == null) {
      throw const CustomerException('Please sign in to delete customers in the cloud.');
    }

    try {
      await sb
          .from('customers')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
      _memoryCustomers.removeWhere((c) => c.id == id);
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(dynamic error) {
    if (error is CustomerException) return error;
    if (error is PostgrestException) {
      if (error.code == '42501' ||
          error.message.toLowerCase().contains('policy') ||
          error.message.toLowerCase().contains('row-level security')) {
        return const CustomerException(
            'Permission denied. Please ensure you are logged in.');
      }
      if (error.code == '23505') {
        return const CustomerException(
            'A customer with this information already exists.');
      }
      return CustomerException(
        error.message.isNotEmpty
            ? error.message
            : 'Database request failed. Please try again.',
        error,
      );
    }
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('socket') ||
        errStr.contains('network') ||
        errStr.contains('timeout') ||
        errStr.contains('clientexception')) {
      return CustomerException(
        'Network error: Unable to reach database. Please check your internet connection.',
        error,
      );
    }
    return CustomerException(
        'Customer operation failed: ', error);
  }
}
