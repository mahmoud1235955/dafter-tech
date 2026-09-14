/// استثناءات خاصة بمسار المصادقة بتاعتنا (مش أخطاء Supabase نفسها).
///
/// بنستخدمها لما نقدر نحدد سبب الفشل بنفسنا ونحوّله لرسالة عربية واضحة.
class AuthFlowException implements Exception {
  const AuthFlowException(this.message);

  final String message;

  @override
  String toString() => 'AuthFlowException: $message';
}
