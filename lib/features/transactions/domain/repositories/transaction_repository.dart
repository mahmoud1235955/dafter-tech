import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, Unit>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({int limit = 50});
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCustomer(String customerId);
  Future<Either<Failure, Unit>> deleteTransaction(String id);
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary();
}
