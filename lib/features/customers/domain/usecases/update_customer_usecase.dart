import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerUseCase implements UseCase<Unit, CustomerEntity> {
  final CustomerRepository repository;

  UpdateCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(CustomerEntity customer) async {
    return await repository.updateCustomer(customer);
  }
}
