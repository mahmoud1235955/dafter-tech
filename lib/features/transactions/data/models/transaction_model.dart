import '../../domain/entities/transaction_entity.dart';

/// نموذج بيانات المعاملة المالية (Transaction Model)
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.customerId,
    super.customerName,
    required super.amount,
    required super.type,
    required super.paymentMethod,
    super.notes,
    super.receiptImageUrl,
    super.bankReferenceNumber,
    required super.transactionDate,
    super.isVerified = false,
    super.isSynced = false,
  });

  /// تحويل من SQLite Map أو Query Result
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String?,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values[(map['type'] as int).clamp(0, TransactionType.values.length - 1)],
      paymentMethod: PaymentMethod.values[(map['paymentMethod'] as int).clamp(0, PaymentMethod.values.length - 1)],
      notes: map['notes'] as String?,
      receiptImageUrl: map['receiptImageUrl'] as String?,
      bankReferenceNumber: map['bankReferenceNumber'] as String?,
      transactionDate: DateTime.parse(map['transactionDate'] as String),
      isVerified: (map['isVerified'] as int?) == 1,
      isSynced: (map['isSynced'] as int?) == 1,
    );
  }

  /// تحويل لـ SQLite Map لحفظها محلياً
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'amount': amount,
      'type': type.index,
      'paymentMethod': paymentMethod.index,
      'notes': notes,
      'receiptImageUrl': receiptImageUrl,
      'bankReferenceNumber': bankReferenceNumber,
      'transactionDate': transactionDate.toIso8601String(),
      'isVerified': isVerified ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  /// تحويل من JSON (Supabase)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values[(json['type'] as int).clamp(0, TransactionType.values.length - 1)],
      paymentMethod: PaymentMethod.values[(json['payment_method'] as int).clamp(0, PaymentMethod.values.length - 1)],
      notes: json['notes'] as String?,
      receiptImageUrl: json['receipt_image_url'] as String?,
      bankReferenceNumber: json['bank_reference_number'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isSynced: true,
    );
  }

  /// تحويل إلى JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount': amount,
      'type': type.index,
      'payment_method': paymentMethod.index,
      'notes': notes,
      'receipt_image_url': receiptImageUrl,
      'bank_reference_number': bankReferenceNumber,
      'transaction_date': transactionDate.toIso8601String(),
      'is_verified': isVerified,
    };
  }

  /// تحويل من Entity إلى Model
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      amount: entity.amount,
      type: entity.type,
      paymentMethod: entity.paymentMethod,
      notes: entity.notes,
      receiptImageUrl: entity.receiptImageUrl,
      bankReferenceNumber: entity.bankReferenceNumber,
      transactionDate: entity.transactionDate,
      isVerified: entity.isVerified,
      isSynced: entity.isSynced,
    );
  }
}
