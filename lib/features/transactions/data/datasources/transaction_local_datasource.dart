import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<void> insertTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getTransactions({int limit = 50});
  Future<List<TransactionModel>> getTransactionsByCustomer(String customerId);
  Future<void> deleteTransaction(String id);
  Future<Map<String, dynamic>> getDashboardSummary();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final DatabaseHelper databaseHelper;

  TransactionLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await databaseHelper.database;

    await db.transaction((txn) async {
      // 1. إضافة المعاملة في جدول المعاملات
      await txn.insert(
        'transactions',
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. تحديث رصيد العميل وتاريخ آخر عملية في جدول العملاء
      final customerResult = await txn.query(
        'customers',
        where: 'id = ?',
        whereArgs: [transaction.customerId],
        limit: 1,
      );

      if (customerResult.isNotEmpty) {
        final currentDebt = (customerResult.first['totalDebt'] as num).toDouble();
        final delta = transaction.type == TransactionType.goodsDelivered
            ? transaction.amount
            : -transaction.amount;

        final newDebt = currentDebt + delta;

        await txn.update(
          'customers',
          {
            'totalDebt': newDebt,
            'lastTransactionAt': transaction.transactionDate.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [transaction.customerId],
        );
      }
    });
  }

  @override
  Future<List<TransactionModel>> getTransactions({int limit = 50}) async {
    final db = await databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT t.*, c.name AS customerName
      FROM transactions t
      LEFT JOIN customers c ON t.customerId = c.id
      ORDER BY t.transactionDate DESC
      LIMIT ?
    ''', [limit]);

    return result.map((row) => TransactionModel.fromMap(row)).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCustomer(String customerId) async {
    final db = await databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT t.*, c.name AS customerName
      FROM transactions t
      LEFT JOIN customers c ON t.customerId = c.id
      WHERE t.customerId = ?
      ORDER BY t.transactionDate DESC
    ''', [customerId]);

    return result.map((row) => TransactionModel.fromMap(row)).toList();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await databaseHelper.database;

    await db.transaction((txn) async {
      final txnQuery = await txn.query('transactions', where: 'id = ?', whereArgs: [id], limit: 1);
      if (txnQuery.isNotEmpty) {
        final model = TransactionModel.fromMap(txnQuery.first);

        // عكس أثر العملية على رصيد العميل
        final customerResult = await txn.query(
          'customers',
          where: 'id = ?',
          whereArgs: [model.customerId],
          limit: 1,
        );

        if (customerResult.isNotEmpty) {
          final currentDebt = (customerResult.first['totalDebt'] as num).toDouble();
          final reverseDelta = model.type == TransactionType.goodsDelivered
              ? -model.amount
              : model.amount;

          await txn.update(
            'customers',
            {'totalDebt': currentDebt + reverseDelta},
            where: 'id = ?',
            whereArgs: [model.customerId],
          );
        }

        await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
      }
    });
  }

  @override
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final db = await databaseHelper.database;

    // 1. حساب إجمالي الديون المستحقة للخارج (لك)
    final debtResult = await db.rawQuery('''
      SELECT SUM(totalDebt) as totalDebtSum
      FROM customers
      WHERE totalDebt > 0
    ''');
    final totalDebtOut = (debtResult.first['totalDebtSum'] as num?)?.toDouble() ?? 0.0;

    // 2. حساب المبالغ المستحقة للعملاء (عليك)
    final creditResult = await db.rawQuery('''
      SELECT SUM(ABS(totalDebt)) as totalCreditSum
      FROM customers
      WHERE totalDebt < 0
    ''');
    final totalCreditOwed = (creditResult.first['totalCreditSum'] as num?)?.toDouble() ?? 0.0;

    // 3. عدد العملاء
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM customers');
    final customerCount = Sqflite.firstIntValue(countResult) ?? 0;

    return {
      'totalDebt': totalDebtOut,
      'totalCredit': totalCreditOwed,
      'customerCount': customerCount,
    };
  }
}
