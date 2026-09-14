import 'package:daftar_tech/core/errors/auth_error_mapper.dart';
import 'package:daftar_tech/core/errors/auth_exceptions.dart';
import 'package:daftar_tech/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapAuthError', () {
    test('يترجم انتهاء صلاحية الرمز', () {
      final failure = mapAuthError(
        AuthException('Token has expired or is invalid'),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('الرمز'));
    });

    test('يترجم الرمز الغلط', () {
      final failure = mapAuthError(AuthException('Invalid token'));

      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('الرمز'));
    });

    test('يترجم تجاوز عدد المحاولات', () {
      final failure = mapAuthError(
        AuthException('over_sms_send_rate_limit'),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('طلبات كتير'));
    });

    test('يترجم أن مزود الهاتف غير مفعل', () {
      final failure = mapAuthError(AuthException('phone_provider_disabled'));

      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('الهاتف'));
    });

    test('يترجم استثناءات مسار المصادقة الداخلية', () {
      final failure = mapAuthError(const AuthFlowException('رسالة مخصصة'));

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'رسالة مخصصة');
    });

    test('يرجع خطأ سيرفر لأي خطأ غير معروف', () {
      final failure = mapAuthError(Exception('something weird'));

      expect(failure, isA<ServerFailure>());
    });
  });
}
