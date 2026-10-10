import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetCustomerTransactionsUseCase implements UseCase<List<TransactionEntity>, String> {
  final TransactionRepository repository;

  GetCustomerTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(String customerId) async {
    return await repository.getTransactionsByCustomer(customerId);
  }
}
