import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';

/// خدمة إدارة الاتصال السريع والتواصل مع العملاء والدعم الفني
class CommunicationService {
  const CommunicationService._();

  /// إرسال تذكير بالدين عبر الواتساب بنص منسق ومهذب
  static Future<bool> sendWhatsAppReminder({
    required String phone,
    required String customerName,
    required double debtAmount,
    String? merchantName,
  }) async {
    final cleanPhone = PhoneFormatter.toE164(phone).replaceAll('+', '');
    final formattedDebt = CurrencyFormatter.format(debtAmount);

    final message = '''
السلام عليكم ورحمة الله وبركاته،
أهلاً بك يا أستاذ $customerName 🌸

تذكير ودي من تطبيق دفترتك بخصوص الحساب المتبقي:
💰 إجمالي المبلغ المستحق: $formattedDebt

شاكرين لتعاملك الراقي دائماً 🙏
${merchantName != null ? 'عن: $merchantName' : ''}
'''.trim();

    return openWhatsAppChat(cleanPhone, message);
  }

  /// فتح محادثة واتساب لرقم معين مع رسالة اختيارية
  static Future<bool> openWhatsAppChat(String phone, [String? text]) async {
    final cleanPhone = PhoneFormatter.toE164(phone).replaceAll('+', '');
    final encodedText = text != null ? Uri.encodeComponent(text) : '';
    final urlString = 'https://wa.me/$cleanPhone${encodedText.isNotEmpty ? '?text=$encodedText' : ''}';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  /// إجراء اتصال هاتفي مباشر
  static Future<bool> makePhoneCall(String phone) async {
    final cleanPhone = PhoneFormatter.toE164(phone);
    final uri = Uri.parse('tel:$cleanPhone');

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    return false;
  }

  /// التواصل مع الدعم الفني
  static Future<bool> contactSupport() async {
    return openWhatsAppChat(
      AppConstants.supportPhone,
      'السلام عليكم، أحتاج مساعدة في تطبيق دفترتك.',
    );
  }
}
