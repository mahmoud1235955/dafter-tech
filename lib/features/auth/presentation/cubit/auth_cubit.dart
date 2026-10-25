import 'dart:async';

import 'package:daftar_tech/core/utils/app_constants.dart';
import 'package:daftar_tech/core/utils/phone_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUserUseCase registerUserUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignOutUseCase signOutUseCase;

  Timer? _resendTimer;
  String _phone = '';
  UserEntity? _currentUser;

  AuthCubit({
    required this.registerUserUseCase,
    required this.sendOtpUseCase,
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial());

  /// المستخدم صاحب الجلسة الحالية (لو موجود).
  UserEntity? get currentUser => _currentUser;

  /// قراءة الجلسة السارية عند فتح التطبيق لعرض بيانات الحساب الحقيقي.
  Future<void> loadCurrentUser() async {
    final result = await getCurrentUserUseCase();

    result.fold(
      (_) {
        _currentUser = null;
      },
      (user) {
        if (user == null) return;
        _currentUser = user;
        _phone = user.phone;
        _emitSafe(AuthAuthenticated(user));
      },
    );
  }

  /// تسجيل الخروج: يمسح جلسة Supabase والنسخة المحلية.
  Future<void> signOut() async {
    _cancelTimer();
    final result = await signOutUseCase();

    result.fold(
      (failure) => _emitSafe(AuthError(failure.message)),
      (_) {
        _currentUser = null;
        _phone = '';
        _emitSafe(const AuthSignedOut());
      },
    );
  }

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
      (user) {
        _currentUser = user;
        _emitSafe(AuthSuccess(user));
      },
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
