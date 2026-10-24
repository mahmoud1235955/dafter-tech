import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.phone,
    super.address,
    required super.totalDebt,
    required super.creditLimit,
    required super.lastTransactionAt,
    super.isSynced,
  });

  // تحويل البيانات القادمة من جدول SQLite إلى Model
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String?,
      totalDebt: (map['totalDebt'] as num).toDouble(),
      creditLimit: (map['creditLimit'] as num).toDouble(),
      lastTransactionAt: DateTime.parse(map['lastTransactionAt'] as String),
      isSynced: (map['isSynced'] as int) == 1,
    );
  }

  // تحويل الـ Model إلى Map لإدخالها في جدول SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'totalDebt': totalDebt,
      'creditLimit': creditLimit,
      'lastTransactionAt': lastTransactionAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  /// تحويل الـ Model إلى JSON مطابق لأعمدة جدول Supabase (snake_case)
  /// ملاحظة: `owner_id` مش بتتبعت من هنا — الجدول بيملأها تلقائياً بـ `auth.uid()`
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'total_debt': totalDebt,
      'credit_limit': creditLimit,
      'last_transaction_at': lastTransactionAt.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  /// تحويل الصفوف القادمة من Supabase (snake_case) إلى Model
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      totalDebt: (json['total_debt'] as num?)?.toDouble() ?? 0,
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0,
      lastTransactionAt: json['last_transaction_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['last_transaction_at'] as String),
      isSynced: json['is_synced'] == true || json['is_synced'] == 1,
    );
  }

  // دالة مساعدة لإنشاء Model انطلاقاً من Entity
  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      totalDebt: entity.totalDebt,
      creditLimit: entity.creditLimit,
      lastTransactionAt: entity.lastTransactionAt,
      isSynced: entity.isSynced,
    );
  }
}
