import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_exceptions.dart';
import 'failures.dart';

/// يحول أي خطأ يطلع من Supabase Auth أو من الشبكة إلى [Failure]
/// برسالة عربية مفهومة تتعرض للمستخدم مباشرة.
Failure mapAuthError(Object error) {
  if (error is AuthFlowException) {
    return ServerFailure(error.message);
  }

  if (error is AuthException) {
    return ServerFailure(_mapAuthMessage(error.message));
  }

  // أخطاء الشبكة: SocketException / ClientException / TimeoutException
  // (مش بنستورد dart:io علشان الكود يفضل شغال على الويب كمان)
  final type = error.runtimeType.toString();
  if (type == 'SocketException' ||
      type == 'ClientException' ||
      type == 'TimeoutException' ||
      type == 'HttpException') {
    return const NetworkFailure();
  }

  final message = error.toString().toLowerCase();
  if (message.contains('failed host lookup') ||
      message.contains('socketexception') ||
      message.contains('network is unreachable') ||
      message.contains('connection timed out') ||
      message.contains('connection refused')) {
    return const NetworkFailure();
  }

  return const ServerFailure();
}

/// تحويل رسائل Supabase Auth الإنجليزية لرسائل عربية.
String _mapAuthMessage(String rawMessage) {
  final message = rawMessage.toLowerCase();

  if (message.contains('otp_disabled')) {
    return 'إرسال رموز التأكيد موقوف حالياً';
  }

  if (message.contains('phone') &&
      (message.contains('disabled') ||
          message.contains('not enabled') ||
          message.contains('provider'))) {
    return 'تسجيل الدخول برقم الهاتف غير مفعل في إعدادات Supabase';
  }

  if (message.contains('invalid token') ||
      message.contains('token has expired or is invalid') ||
      message.contains('invalid or has expired') ||
      message.contains('otp_expired') ||
      message.contains('token has expired') ||
      message.contains('expired')) {
    return 'الرمز غير صحيح أو انتهت صلاحيته، اطلب رمز جديد';
  }

  if (message.contains('rate limit') ||
      message.contains('over_sms_send_rate_limit') ||
      message.contains('for security purposes')) {
    return 'طلبات كتير في وقت قصير، استنى شوية واطلب الرمز تاني';
  }

  if (message.contains('invalid') && message.contains('phone')) {
    return 'رقم الهاتف غير صحيح أو غير مدعوم من خدمة الرسائل';
  }

  if (message.contains('sms_send_failed') ||
      message.contains('error sending') ||
      message.contains('unable to send')) {
    return 'فشل إرسال رسالة التأكيد، راجع إعدادات مزود الرسائل في Supabase';
  }

  if (message.contains('user_already_exists')) {
    return 'الرقم مسجل بالفعل';
  }

  return 'حدث خطأ أثناء التواصل مع السحابة، حاول تاني';
}
