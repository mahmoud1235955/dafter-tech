import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, Unit>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);

      // 1. الحفظ المحلي وتحديث رصيد العميل فوراً (Offline-First)
      await localDataSource.insertTransaction(model);

      // 2. المزامنة مع Supabase في الخلفية لو متصلين بالإنترنت
      final connectivityResult = await connectivity.checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        try {
          await remoteDataSource.uploadTransaction(model);
        } catch (_) {
          // البيانات محفوظة محلياً بنجاح
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({int limit = 50}) async {
    try {
      final transactions = await localDataSource.getTransactions(limit: limit);
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCustomer(String customerId) async {
    try {
      final transactions = await localDataSource.getTransactionsByCustomer(customerId);
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary() async {
    try {
      final summary = await localDataSource.getDashboardSummary();
      return Right(summary);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
