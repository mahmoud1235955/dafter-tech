import 'package:flutter/material.dart';

/// نظام الألوان المعتمد لتطبيق «دفترتك | DaftarTech»
/// متوافق مع الهوية البصرية الرسمية (Sky & Deep Blue + Teal + Coral)
abstract class AppColors {
  // الألوان الأساسية للهوية البصرية
  static const Color primary = Color(0xFF0265B8); // أزرق دفترتك الأساسي
  static const Color primaryLight = Color(0xFF0284C7); // أزرق سماوي مضيء
  static const Color primaryDark = Color(0xFF034E8C); // أزرق داكن
  static const Color navy = Color(0xFF0B1E36); // كحلي شاشة البداية
  static const Color accent = Color(0xFF0EA5E9); // لون التمييز التفاعلي

  // المؤشرات المالية (Financial Indicators)
  static const Color moneyIn = Color(0xFF10B981); // تحصيل / سداد / له (أخضر تيل)
  static const Color moneyInLight = Color(0xFFE8FDF5);
  static const Color moneyOut = Color(0xFFEF4444); // دين / عليه / آجل (أحمر مرجاني)
  static const Color moneyOutLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B); // تنبيه / فحص إيصال (برتقالي)
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF3B82F6); // معلومات (أزرق)
  static const Color gold = Color(0xFFF59E0B); // شارات ذهبية

  // الخلفيات والأسطح (Canvas & Backgrounds)
  static const Color scaffoldBackground = Color(0xFFF1F5F9); // رمادي فاتح مائل للأزرق
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // حقول الإدخال والاستمارات
  static const Color fieldFill = Color(0xFFF8FAFC);
  static const Color fieldBorder = Color(0xFFCBD5E1);
  static const Color otpFieldFill = Color(0xFFEBF4FE);
  static const Color submitButton = Color(0xFF0265B8);
  static const Color selectedOption = Color(0xFF03629A);

  // ألوان النصوص (Typography)
  static const Color textPrimary = Color(0xFF0F172A); // أسود داكن كحلي
  static const Color textSecondary = Color(0xFF64748B); // رمادي متوسط
  static const Color textMuted = Color(0xFF94A3B8); // رمادي فاتح
  static const Color textWhite = Color(0xFFFFFFFF);

  // التدرجات اللونية (Gradients)
  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0B1E36), Color(0xFF024B8A), Color(0xFF0265B8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0265B8), Color(0xFF0284C7)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient cardBalanceGradient = LinearGradient(
    colors: [Color(0xFF0265B8), Color(0xFF0D9488)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient moneyInGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient moneyOutGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
