import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<void> uploadCustomer(CustomerModel customer);
  Future<List<CustomerModel>> fetchCustomers();
  Future<void> syncUnsyncedCustomers(List<CustomerModel> unsyncedCustomers);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final SupabaseClient supabaseClient;

  CustomerRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> uploadCustomer(CustomerModel customer) async {
    // نرفع البيانات ونعلمها كـ synced في السيرفر
    final data = customer.toMap();
    data['isSynced'] = 1;

    await supabaseClient.from('customers').upsert(data);
  }

  @override
  Future<List<CustomerModel>> fetchCustomers() async {
    final response = await supabaseClient
        .from('customers')
        .select()
        .order('lastTransactionAt', ascending: false);

    return (response as List)
        .map((json) => CustomerModel.fromMap(json))
        .toList();
  }

  @override
  Future<void> syncUnsyncedCustomers(
    List<CustomerModel> unsyncedCustomers,
  ) async {
    if (unsyncedCustomers.isEmpty) return;

    final batchData = unsyncedCustomers.map((c) {
      final map = c.toMap();
      map['isSynced'] = 1;
      return map;
    }).toList();

    await supabaseClient.from('customers').upsert(batchData);
  }
}
