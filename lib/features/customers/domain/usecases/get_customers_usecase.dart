import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase implements UseCase<List<CustomerEntity>, NoParams> {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<CustomerEntity>>> call(NoParams params) async {
    return await repository.getCustomers();
  }
}
