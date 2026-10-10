import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> recentTransactions;
  final double totalDebt;
  final double totalCredit;
  final int customerCount;

  const TransactionLoaded({
    required this.recentTransactions,
    required this.totalDebt,
    required this.totalCredit,
    required this.customerCount,
  });

  @override
  List<Object?> get props => [
    recentTransactions,
    totalDebt,
    totalCredit,
    customerCount,
  ];
}

class CustomerTransactionsLoaded extends TransactionState {
  final List<TransactionEntity> transactions;

  const CustomerTransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionActionSuccess extends TransactionState {
  final String message;
  const TransactionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
