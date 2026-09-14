import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;
  RegisterUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String phone,
    required String otp,
    required BusinessType businessType,
  }) async {
    return await repository.verifyOtpAndRegister(
      phone: phone,
      otp: otp,
      businessType: businessType,
    );
  }
}
