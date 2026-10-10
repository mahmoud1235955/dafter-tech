import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

export 'phone_formatter.dart';

/// منسق المبالغ والعملات المالية
class CurrencyFormatter {
  const CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,##0.##', 'ar');
  static final NumberFormat _latinFormatter = NumberFormat('#,##0.##', 'en_US');

  /// تنسيق المبلغ مع رمز العملة العربي (مثال: 12,450 ج.م)
  static String format(double amount, {bool useLatinDigits = false}) {
    final formatted = useLatinDigits
        ? _latinFormatter.format(amount)
        : _formatter.format(amount);
    return '$formatted ${AppConstants.currencyEgp}';
  }

  /// تنسيق المبلغ كرقم فقط بدون رمز العملة
  static String formatAmountOnly(double amount, {bool useLatinDigits = false}) {
    return useLatinDigits
        ? _latinFormatter.format(amount)
        : _formatter.format(amount);
  }

  /// تنسيق الإشارة (+ / -)
  static String formatSigned(double amount, {required bool isDebit}) {
    final prefix = isDebit ? '-' : '+';
    return '$prefix ${format(amount.abs())}';
  }
}

/// منسق التواريخ والأوقات باللغة العربية
class DateFormatter {
  const DateFormatter._();

  static final DateFormat _fullArabicDate = DateFormat('d MMMM yyyy', 'ar');
  static final DateFormat _shortDate = DateFormat('d MMMM', 'ar');
  static final DateFormat _timeFormat = DateFormat('hh:mm a', 'ar');

  static String formatFull(DateTime date) {
    return _fullArabicDate.format(date);
  }

  static String formatShort(DateTime date) {
    return _shortDate.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// تنسيق نسبي وذكي (اليوم 10:30 ص / أمس 05:15 م / 22 أكتوبر 2026)
  static String formatSmart(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      return 'اليوم ${_timeFormat.format(date)}';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
      return 'أمس ${_timeFormat.format(date)}';
    } else if (now.year == date.year) {
      return '${_shortDate.format(date)} - ${_timeFormat.format(date)}';
    } else {
      return '${_fullArabicDate.format(date)}';
    }
  }
}
