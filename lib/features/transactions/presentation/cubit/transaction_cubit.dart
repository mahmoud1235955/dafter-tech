import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_customer_transactions_usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetCustomerTransactionsUseCase getCustomerTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  TransactionCubit({
    required this.getTransactionsUseCase,
    required this.getCustomerTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getDashboardStatsUseCase,
  }) : super(TransactionInitial());

  Future<void> loadDashboardData() async {
    emit(TransactionLoading());

    final statsResult = await getDashboardStatsUseCase(NoParams());
    final transactionsResult = await getTransactionsUseCase(20);

    statsResult.fold(
      (failure) => emit(TransactionError(failure.message)),
      (stats) {
        transactionsResult.fold(
          (failure) => emit(TransactionError(failure.message)),
          (transactions) {
            emit(
              TransactionLoaded(
                recentTransactions: transactions,
                totalDebt: (stats['totalDebt'] as num).toDouble(),
                totalCredit: (stats['totalCredit'] as num).toDouble(),
                customerCount: stats['customerCount'] as int,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> loadCustomerTransactions(String customerId) async {
    emit(TransactionLoading());
    final result = await getCustomerTransactionsUseCase(customerId);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(CustomerTransactionsLoaded(transactions)),
    );
  }

  Future<void> createTransaction(TransactionEntity transaction) async {
    emit(TransactionLoading());
    final result = await addTransactionUseCase(transaction);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) async {
        emit(const TransactionActionSuccess('تم تسجيل وحفظ المعاملة بنجاح'));
        await loadDashboardData();
      },
    );
  }

  Future<void> removeTransaction(String id, {String? customerId}) async {
    emit(TransactionLoading());
    final result = await deleteTransactionUseCase(id);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) async {
        emit(const TransactionActionSuccess('تم حذف المعاملة وتعديل الحساب'));
        if (customerId != null) {
          await loadCustomerTransactions(customerId);
        } else {
          await loadDashboardData();
        }
      },
    );
  }
}
