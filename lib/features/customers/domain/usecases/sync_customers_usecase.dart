import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/customer_repository.dart';

class SyncCustomersUseCase implements UseCase<Unit, NoParams> {
  final CustomerRepository repository;

  SyncCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.syncOfflineCustomers();
  }
}
