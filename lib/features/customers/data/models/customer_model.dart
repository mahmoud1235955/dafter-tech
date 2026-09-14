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
