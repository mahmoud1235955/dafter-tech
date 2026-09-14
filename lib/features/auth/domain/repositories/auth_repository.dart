import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// إرسال رمز تأكيد على الرقم (بصيغة E.164).
  Future<Either<Failure, Unit>> sendOtp(String phone);

  /// التحقق من الرمز عند Supabase وإنشاء/تحديث الملف الشخصي.
  Future<Either<Failure, UserEntity>> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  });

  /// المستخدم الحالي (من الجلسة السحابية أو النسخة المحلية) أو `null`.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// تسجيل الخروج (يمسح الجلسة والنسخة المحلية).
  Future<Either<Failure, Unit>> signOut();
}
