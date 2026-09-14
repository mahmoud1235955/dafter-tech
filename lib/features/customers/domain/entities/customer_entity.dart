import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final double totalDebt; // إجمالي الرصيد القائم (ليك بره)
  final double creditLimit; // سقف الآجل المسموح
  final DateTime lastTransactionAt;
  final bool isSynced;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.totalDebt,
    required this.creditLimit,
    required this.lastTransactionAt,
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    address,
    totalDebt,
    creditLimit,
    lastTransactionAt,
    isSynced,
  ];
}
