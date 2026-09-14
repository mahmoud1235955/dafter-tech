import 'app_constants.dart';
import 'phone_formatter.dart';

/// رسائل وتحقق مدخلات نماذج المصادقة (الهاتف ورمز التأكيد).
abstract class Validators {
  Validators._();

  /// عدد خانات رمز التأكيد (نفس إعداد Supabase).
  static const int otpLength = AppConstants.otpLength;

  static final RegExp _nonDigits = RegExp(r'\D');

  /// يتحقق من رقم الهاتف ويرجع رسالة الخطأ أو `null` لو سليم.
  static String? validatePhone(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return 'من فضلك أدخل رقم الهاتف';
    if (!PhoneFormatter.isValid(value)) {
      return 'رقم الهاتف غير صحيح، لازم 11 رقم ويبدأ بـ 010 أو 011 أو 012 أو 015';
    }
    return null;
  }

  /// يتحقق من رمز التأكيد ويرجع رسالة الخطأ أو `null` لو سليم.
  static String? validateOtp(String? raw) {
    final digits = (raw ?? '').replaceAll(_nonDigits, '');
    if (digits.isEmpty) return 'من فضلك أدخل رمز التأكيد';
    if (digits.length != otpLength) {
      return 'رمز التأكيد لازم يكون $otpLength أرقام';
    }
    return null;
  }

  /// يرجع الرمز بعد تنظيفه من أي رموز غير الأرقام.
  static String cleanOtp(String raw) => raw.replaceAll(_nonDigits, '');
}
