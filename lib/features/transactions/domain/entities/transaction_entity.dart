import 'package:equatable/equatable.dart';

enum TransactionType {
  goodsDelivered, // سلمت بضاعة (+ دين على العميل)
  paymentReceived, // استلمت سداد (- نقص من دينه)
}

enum PaymentMethod { cash, instaPay, vodafoneCash, other }

class TransactionEntity extends Equatable {
  final String id;
  final String customerId;
  final double amount;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final String? notes;
  final String? receiptImageUrl;
  final String? bankReferenceNumber;
  final DateTime transactionDate;
  final bool isVerified; // هل مطابقة الإيصال مؤكدة
  final bool isSynced;

  const TransactionEntity({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    this.notes,
    this.receiptImageUrl,
    this.bankReferenceNumber,
    required this.transactionDate,
    this.isVerified = false,
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [
    id,
    customerId,
    amount,
    type,
    paymentMethod,
    notes,
    receiptImageUrl,
    bankReferenceNumber,
    transactionDate,
    isVerified,
    isSynced,
  ];
}
