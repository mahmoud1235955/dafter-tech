import 'package:equatable/equatable.dart';

enum BusinessType { grocery, wholesaler, onlineStore }

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final BusinessType businessType;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.businessType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, phone, businessType, createdAt];
}
