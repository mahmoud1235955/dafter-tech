import 'package:equatable/equatable.dart';

enum TransactionType {
  goodsDelivered, // سلمت بضاعة (+ دين على العميل / عليه)
  paymentReceived, // استلمت سداد (- نقص من دينه / له)
}

enum PaymentMethod {
  cash, // نقداً
  instaPay, // انستاباي InstaPay
  vodafoneCash, // فودافون كاش
  bankTransfer, // تحويل بنكي
  other, // أخرى
}

class TransactionEntity extends Equatable {
  final String id;
  final String customerId;
  final String? customerName; // اسم العميل المربوط بالمعاملة
  final double amount;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final String? notes; // بيان المعاملة
  final String? receiptImageUrl;
  final String? bankReferenceNumber;
  final DateTime transactionDate;
  final bool isVerified; // هل مطابقة الإيصال مؤكدة
  final bool isSynced;

  const TransactionEntity({
    required this.id,
    required this.customerId,
    this.customerName,
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

  bool get isDebt => type == TransactionType.goodsDelivered;

  @override
  List<Object?> get props => [
    id,
    customerId,
    customerName,
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
