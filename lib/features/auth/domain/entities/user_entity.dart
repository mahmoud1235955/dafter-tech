import 'package:equatable/equatable.dart';

enum BusinessType { grocery, wholesaler, onlineStore }

/// التسمية العربية لنوع النشاط لعرضها في الواجهة.
extension BusinessTypeLabel on BusinessType {
  String get labelAr {
    switch (this) {
      case BusinessType.grocery:
        return 'بقالة / محل';
      case BusinessType.wholesaler:
        return 'موزع / جملة';
      case BusinessType.onlineStore:
        return 'مشروع منزلي / أونلاين';
    }
  }
}

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
