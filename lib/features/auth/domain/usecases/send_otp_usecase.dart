import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// إرسال رمز تأكيد (OTP) على رقم الهاتف.
class SendOtpUseCase {
  final AuthRepository repository;

  const SendOtpUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String phone) async {
    return await repository.sendOtp(phone);
  }
}
