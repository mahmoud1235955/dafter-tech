/// ثوابت التطبيق العامة (مكان واحد لأي قيمة تتكرر في الشاشات).
class AppConstants {
  const AppConstants._();

  /// رقم الدعم الفني (واتساب) - يتم تحديثه برقم الدعم الحقيقي.
  static const String supportPhone = '01000000000';

  /// الاسم الظاهر في رسالة الواتساب للدعم الفني.
  static const String supportName = 'الدعم الفني';

  /// إصدار التطبيق الظاهر في أسفل الشاشات.
  static const String appVersion = '2.4';

  /// عدد خانات رمز التأكيد.
  static const int otpLength = 4;

  /// مدة الانتظار (بالثواني) قبل السماح بإعادة إرسال الرمز.
  static const int otpResendCooldownSeconds = 60;
}
