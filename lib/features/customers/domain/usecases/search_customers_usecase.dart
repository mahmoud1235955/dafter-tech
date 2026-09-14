import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class SearchCustomersUseCase implements UseCase<List<CustomerEntity>, String> {
  final CustomerRepository repository;

  SearchCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<CustomerEntity>>> call(String query) async {
    return await repository.searchCustomers(query);
  }
}
