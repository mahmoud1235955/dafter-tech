/// ثوابت التطبيق العامة
class AppConstants {
  const AppConstants._();

  static const String appName = 'دفترتك';
  static const String appNameEn = 'DaftarTech';
  static const String appSlogan = 'دفترك الذكي.. وفلوسك في أمان ✨';
  static const String appVersion = 'v2.4';
  
  static const String currencyEgp = 'ج.م';
  static const String currencyEgpEn = 'EGP';

  /// اللغة الافتراضية للتطبيق (عربية مصرية)
  static const String defaultLocale = 'ar';
  static const String defaultLocaleCountry = 'EG';

  /// رقم الدعم الفني (واتساب)
  static const String supportPhone = '01000000000';
  static const String supportName = 'الدعم الفني لدفترتك';

  /// إعدادات رمز التأكيد OTP
  static const int otpLength = 6;
  static const int otpResendCooldownSeconds = 60;

  /// الرابط الافتراضي ومفتاح Supabase
  static const String defaultSupabaseUrl = 'https://gkmswfzekvqxdcwyphot.supabase.co';
  static const String defaultSupabaseAnonKey = 'sb_publishable_id75XirRunhYcp_8qwkcqg_6sSWsIYx';
}
