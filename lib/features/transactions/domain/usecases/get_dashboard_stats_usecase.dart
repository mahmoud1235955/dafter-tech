import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/transaction_repository.dart';

class GetDashboardStatsUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final TransactionRepository repository;

  GetDashboardStatsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getDashboardSummary();
  }
}
