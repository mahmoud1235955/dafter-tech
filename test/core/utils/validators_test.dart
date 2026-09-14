import 'package:daftar_tech/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.validatePhone', () {
    test('يرجع رسالة لو الحقل فارغ', () {
      expect(Validators.validatePhone(''), isNotNull);
      expect(Validators.validatePhone(null), isNotNull);
      expect(Validators.validatePhone('   '), isNotNull);
    });

    test('يرجع رسالة لو الرقم غير مصري صحيح', () {
      expect(Validators.validatePhone('010987'), isNotNull);
      expect(Validators.validatePhone('01998765432'), isNotNull);
    });

    test('يرجع null لو الرقم سليم', () {
      expect(Validators.validatePhone('01098765432'), isNull);
      expect(Validators.validatePhone(' +201098765432 '), isNull);
    });
  });

  group('Validators.validateOtp', () {
    test('يرجع رسالة لو الرمز فارغ', () {
      expect(Validators.validateOtp(''), isNotNull);
      expect(Validators.validateOtp(null), isNotNull);
    });

    test('يرجع رسالة لو الرمز ناقص', () {
      expect(Validators.validateOtp('42'), isNotNull);
    });

    test('يرجع null لو الرمز مكتمل', () {
      expect(Validators.validateOtp('4285'), isNull);
    });

    test('يتجاهل أي رموز غير الأرقام', () {
      expect(Validators.validateOtp('4-2-8-5'), isNull);
    });
  });

  group('Validators.cleanOtp', () {
    test('يستخرج الأرقام فقط', () {
      expect(Validators.cleanOtp('4 2-8a5'), '4285');
    });
  });
}
