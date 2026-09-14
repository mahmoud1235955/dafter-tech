/// أدوات التعامل مع أرقام الهواتف المصرية (تنسيق + تحقق + صيغة دولية).
class PhoneFormatter {
  const PhoneFormatter._();

  static const String countryCode = '20';

  /// طول الرقم بالصفر الأول: 01XXXXXXXXX
  static const int localLength = 11;

  /// طول الرقم بدون الصفر الأول: 1XXXXXXXXX
  static const int nationalLength = 10;

  static final RegExp _nonDigits = RegExp(r'\D');

  /// الرموز الصحيحة لبداية رقم موبايل مصري.
  static const List<String> _mobilePrefixes = ['010', '011', '012', '015'];

  /// يرجع الرقم بعد إزالة أي رموز زائدة وتوحيد الصيغة إلى 01XXXXXXXXX
  ///
  /// أمثلة:
  /// - `01098765432` ← `01098765432`
  /// - `+20 109 876 5432` ← `01098765432`
  /// - `00201098765432` ← `01098765432`
  static String normalize(String raw) {
    var digits = raw.replaceAll(_nonDigits, '');

    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    if (digits.startsWith(countryCode) && digits.length > nationalLength) {
      digits = digits.substring(countryCode.length);
    }

    if (digits.isNotEmpty && !digits.startsWith('0')) {
      digits = '0$digits';
    }

    return digits;
  }

  /// هل الرقم موبايل مصري صحيح أم لا؟
  static bool isValid(String raw) {
    final digits = normalize(raw);
    if (digits.length != localLength) return false;
    return _mobilePrefixes.any((prefix) => digits.startsWith(prefix));
  }

  /// الصيغة الدولية المطلوبة لخدمات المصادقة: `+201XXXXXXXXX`
  ///
  /// ترجع نص فارغ لو الرقم غير صحيح.
  static String toE164(String raw) {
    final digits = normalize(raw);
    if (!isValid(digits)) return '';
    return '+$countryCode${digits.substring(1)}';
  }

  /// صيغة للعرض داخل التطبيق: `0109 876 5432`
  static String display(String raw) {
    final digits = normalize(raw);
    if (digits.length != localLength) return raw.trim();
    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
  }
}
