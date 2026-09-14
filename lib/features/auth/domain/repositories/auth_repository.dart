import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> sendOtp(String phone);
  Future<Either<Failure, UserEntity>> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  });
}
