import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<void> uploadCustomer(CustomerModel customer);
  Future<List<CustomerModel>> fetchCustomers();
  Future<void> syncUnsyncedCustomers(List<CustomerModel> unsyncedCustomers);
  Future<void> deleteCustomer(String id);
}

/// مزامنة العملاء مع جدول `customers` في Supabase.
///
/// أسماء الأعمدة في السيرفر snake_case (`total_debt`, `credit_limit`,
/// `last_transaction_at`, `is_synced`) بينما الجدول المحلي في SQLite لسه
/// camelCase — لذلك `toMap()/fromMap()` للـ SQLite و`toJson()/fromJson()` للسيرفر.
///
/// عمود `owner_id` مش بتبعت من هنا: الجدول بيملأه تلقائياً بـ `auth.uid()`
/// وسياسات RLS بتتأكد إن المستخدم بيكتب في صفوفه هو بس.
class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  static const String tableName = 'customers';

  final SupabaseClient supabaseClient;

  CustomerRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> uploadCustomer(CustomerModel customer) async {
    // نرفع البيانات ونعلمها كـ synced في السيرفر
    final data = customer.toJson();
    data['is_synced'] = true;

    await supabaseClient.from(tableName).upsert(data);
  }

  @override
  Future<List<CustomerModel>> fetchCustomers() async {
    final response = await supabaseClient
        .from(tableName)
        .select()
        .order('last_transaction_at', ascending: false);

    return (response as List)
        .map((json) => CustomerModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> syncUnsyncedCustomers(
    List<CustomerModel> unsyncedCustomers,
  ) async {
    if (unsyncedCustomers.isEmpty) return;

    final batchData = unsyncedCustomers.map((c) {
      final map = c.toJson();
      map['is_synced'] = true;
      return map;
    }).toList();

    await supabaseClient.from(tableName).upsert(batchData);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await supabaseClient.from(tableName).delete().eq('id', id);
  }
}
