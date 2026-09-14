import 'dart:async';

import 'package:daftar_tech/core/utils/app_constants.dart';
import 'package:daftar_tech/core/utils/phone_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUserUseCase registerUserUseCase;
  final SendOtpUseCase sendOtpUseCase;

  Timer? _resendTimer;
  String _phone = '';

  AuthCubit({
    required this.registerUserUseCase,
    required this.sendOtpUseCase,
  }) : super(AuthInitial());

  /// عدد الثواني المتبقية قبل السماح بإعادة إرسال الرمز.
  int get remainingSeconds => state is AuthOtpSent
      ? (state as AuthOtpSent).cooldown
      : 0;

  /// هل يمكن إعادة إرسال الرمز الآن؟
  bool get canResendOtp => remainingSeconds <= 0;

  /// إرسال/إعادة إرسال رمز التأكيد على رقم الهاتف.
  Future<void> sendOtp(String phone) async {
    final normalized = PhoneFormatter.normalize(phone);

    if (!PhoneFormatter.isValid(normalized)) {
      _emitSafe(const AuthOtpError('من فضلك أدخل رقم هاتف صحيح أولاً'));
      return;
    }

    // منع الإرسال المتكرر أثناء العد التنازلي،
    // مع السماح بالإرسال فوراً لو المستخدم غيّر الرقم.
    if (!canResendOtp && normalized == _phone) return;

    _phone = normalized;
    _emitSafe(const AuthOtpSending());

    final result = await sendOtpUseCase(PhoneFormatter.toE164(normalized));

    result.fold(
      (failure) => _emitSafe(AuthOtpError(failure.message)),
      (_) => _startResendCooldown(),
    );
  }

  /// التحقق من الرمز وإنشاء الحساب (أو مزامنته محلياً عند عدم وجود إنترنت).
  Future<void> submitRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  }) async {
    // إيقاف عداد إعادة الإرسال أثناء إنشاء الحساب
    _cancelTimer();

    _phone = PhoneFormatter.normalize(phone);

    _emitSafe(const AuthLoading());

    final result = await registerUserUseCase(
      phone: PhoneFormatter.toE164(_phone),
      otp: otp,
      businessType: businessType,
    );

    result.fold(
      (failure) => _emitSafe(AuthError(failure.message)),
      (user) => _emitSafe(AuthSuccess(user)),
    );
  }

  /// بدء العد التنازلي الخاص بإعادة إرسال الرمز.
  void _startResendCooldown() {
    _cancelTimer();
    _emitSafe(
      AuthOtpSent(
        phone: _phone,
        cooldown: AppConstants.otpResendCooldownSeconds,
      ),
    );

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = AppConstants.otpResendCooldownSeconds - timer.tick;

      if (remaining <= 0) {
        timer.cancel();
        _resendTimer = null;
        _emitSafe(AuthOtpSent(phone: _phone, cooldown: 0));
      } else {
        _emitSafe(AuthOtpSent(phone: _phone, cooldown: remaining));
      }
    });
  }

  void _cancelTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  void _emitSafe(AuthState state) {
    if (!isClosed) emit(state);
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
