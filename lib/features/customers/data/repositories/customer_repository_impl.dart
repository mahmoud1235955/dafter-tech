import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;
  final CustomerRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  CustomerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers() async {
    try {
      final localCustomers = await localDataSource.getCustomers();
      return Right(localCustomers);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id) async {
    try {
      final customer = await localDataSource.getCustomerById(id);
      if (customer != null) {
        return Right(customer);
      }
      return const Left(DatabaseFailure('العميل غير موجود'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addCustomer(CustomerEntity customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);

      // 1. الحفظ الفوري في قاعدة البيانات المحلية
      await localDataSource.cacheCustomer(model);

      // 2. محاولة المزامنة السحابية في الخلفية إذا وُجد إنترنت
      final connectivityResult = await connectivity.checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        try {
          await remoteDataSource.uploadCustomer(model);
          await localDataSource.updateCustomer(
            CustomerModel.fromMap({...model.toMap(), 'isSynced': 1}),
          );
        } catch (_) {
          // نتجاهل خطأ السيرفر هنا لأن البيانات محفوظة محلياً بالفعل
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCustomer(CustomerEntity customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      await localDataSource.updateCustomer(model);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerEntity>>> searchCustomers(
    String query,
  ) async {
    try {
      final results = await localDataSource.searchCustomers(query);
      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCustomer(String id) async {
    try {
      await localDataSource.deleteCustomer(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncOfflineCustomers() async {
    try {
      final localCustomers = await localDataSource.getCustomers();
      final unsynced = localCustomers.where((c) => !c.isSynced).toList();

      if (unsynced.isNotEmpty) {
        await remoteDataSource.syncUnsyncedCustomers(unsynced);
        for (var customer in unsynced) {
          await localDataSource.updateCustomer(
            CustomerModel.fromMap({...customer.toMap(), 'isSynced': 1}),
          );
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
