import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<void> uploadTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> fetchTransactions();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient supabaseClient;

  TransactionRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> uploadTransaction(TransactionModel transaction) async {
    final data = transaction.toJson();
    await supabaseClient.from('transactions').upsert(data);
  }

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    final response = await supabaseClient
        .from('transactions')
        .select('*, customers(name)')
        .order('transaction_date', ascending: false);

    return (response as List).map((json) {
      final customerName = json['customers'] != null ? json['customers']['name'] as String? : null;
      final map = Map<String, dynamic>.from(json);
      map['customer_name'] = customerName;
      return TransactionModel.fromJson(map);
    }).toList();
  }
}
