import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  // فتح شات واتساب برقم مصري ورسالة جاهزة
  static Future<void> sendWhatsAppReminder({
    required String phone,
    required String customerName,
    required double debtAmount,
  }) async {
    // تجهيز الرقم المصري بالصيغة الدولية (+20)
    String cleanPhone = phone.replaceAll(RegExp(r'\s+|-'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '2$cleanPhone';
    } else if (!cleanPhone.startsWith('20')) {
      cleanPhone = '20$cleanPhone';
    }

    final message = Uri.encodeComponent(
      'السلام عليكم يا أستاذ $customerName، '
      'نود تذكير سيادتكم بأن إجمالي الحساب المتبقي في الدفتر هو: ${debtAmount.toStringAsFixed(0)} ج.م. '
      'شاكرين لتعاونكم.',
    );

    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // إجراء مكالمة هاتفية سريعة
  static Future<void> makePhoneCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
