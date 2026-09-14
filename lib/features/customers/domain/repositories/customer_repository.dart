import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers();
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id);
  Future<Either<Failure, Unit>> addCustomer(CustomerEntity customer);
  Future<Either<Failure, Unit>> updateCustomer(CustomerEntity customer);
  Future<Either<Failure, List<CustomerEntity>>> searchCustomers(String query);
  Future<Either<Failure, Unit>> deleteCustomer(String id);
  Future<Either<Failure, Unit>> syncOfflineCustomers();
}
