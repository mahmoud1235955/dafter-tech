import 'package:daftar_tech/core/database/data_base_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../models/customer_model.dart';

abstract class CustomerLocalDataSource {
  Future<void> cacheCustomer(CustomerModel customer);
  Future<List<CustomerModel>> getCustomers();
  Future<CustomerModel?> getCustomerById(String id);
  Future<void> updateCustomer(CustomerModel customer);
  Future<List<CustomerModel>> searchCustomers(String query);
  Future<void> deleteCustomer(String id);
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final DatabaseHelper databaseHelper;

  CustomerLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<void> cacheCustomer(CustomerModel customer) async {
    final db = await databaseHelper.database;
    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'customers',
      orderBy: 'lastTransactionAt DESC',
    );
    return result.map((json) => CustomerModel.fromMap(json)).toList();
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return CustomerModel.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    final db = await databaseHelper.database;
    await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'customers',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'lastTransactionAt DESC',
    );
    return result.map((json) => CustomerModel.fromMap(json)).toList();
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final db = await databaseHelper.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
