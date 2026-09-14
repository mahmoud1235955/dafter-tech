import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase implements UseCase<Unit, String> {
  final CustomerRepository repository;

  DeleteCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String customerId) async {
    return await repository.deleteCustomer(customerId);
  }
}
