import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([
    super.message = 'حدث خطأ أثناء حفظ أو قراءة البيانات محلياً',
  ]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الاتصال بالخادم السحابي']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}
