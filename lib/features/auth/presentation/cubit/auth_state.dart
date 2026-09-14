import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية (قبل أي تفاعل من المستخدم).
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// جارٍ التحقق من الرمز وإنشاء الحساب.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// تم إنشاء الحساب/تسجيل الدخول بنجاح.
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// فشل التحقق من الرمز أو إنشاء الحساب.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// جارٍ إرسال رمز التأكيد على الرقم.
class AuthOtpSending extends AuthState {
  const AuthOtpSending();
}

/// تم إرسال الرمز، و[cooldown] هو عدد الثواني المتبقية قبل إعادة الإرسال.
class AuthOtpSent extends AuthState {
  final String phone;
  final int cooldown;

  const AuthOtpSent({required this.phone, required this.cooldown});

  bool get canResend => cooldown <= 0;

  @override
  List<Object?> get props => [phone, cooldown];
}

/// فشل إرسال رمز التأكيد.
class AuthOtpError extends AuthState {
  final String message;

  const AuthOtpError(this.message);

  @override
  List<Object?> get props => [message];
}
