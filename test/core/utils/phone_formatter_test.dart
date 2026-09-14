import 'package:daftar_tech/core/utils/phone_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneFormatter.normalize', () {
    test('يترك الرقم المحلي كما هو', () {
      expect(PhoneFormatter.normalize('01098765432'), '01098765432');
    });

    test('يزيل المسافات والشرطات', () {
      expect(PhoneFormatter.normalize('010 987 654 32'), '01098765432');
      expect(PhoneFormatter.normalize('010-987-654-32'), '01098765432');
    });

    test('يحول الصيغة الدولية للمحلية', () {
      expect(PhoneFormatter.normalize('+201098765432'), '01098765432');
      expect(PhoneFormatter.normalize('00201098765432'), '01098765432');
      expect(PhoneFormatter.normalize('201098765432'), '01098765432');
    });

    test('يرجع نص فارغ لو المدخل فارغ', () {
      expect(PhoneFormatter.normalize(''), '');
      expect(PhoneFormatter.normalize('abc'), '');
    });
  });

  group('PhoneFormatter.isValid', () {
    test('يقبل أرقام الموبايل المصرية الصحيحة', () {
      for (final phone in [
        '01098765432',
        '01198765432',
        '01298765432',
        '01598765432',
        '+201098765432',
      ]) {
        expect(PhoneFormatter.isValid(phone), isTrue, reason: phone);
      }
    });

    test('يرفض الأرقام الناقصة أو الزائدة أو بمقدمة خطأ', () {
      for (final phone in [
        '',
        '0109876543', // 10 أرقام
        '010987654321', // 12 رقم
        '01998765432', // مقدمة غير صحيحة
        '02098765432', // أرضي
      ]) {
        expect(PhoneFormatter.isValid(phone), isFalse, reason: phone);
      }
    });
  });

  group('PhoneFormatter.toE164', () {
    test('يرجع الصيغة الدولية للرقم الصحيح', () {
      expect(PhoneFormatter.toE164('01098765432'), '+201098765432');
      expect(PhoneFormatter.toE164('+201098765432'), '+201098765432');
    });

    test('يرجع نص فارغ للرقم غير الصحيح', () {
      expect(PhoneFormatter.toE164('01098'), '');
    });
  });

  group('PhoneFormatter.display', () {
    test('يقسم الرقم لمجموعات للعرض', () {
      expect(PhoneFormatter.display('01098765432'), '0109 876 5432');
    });

    test('يرجع المدخل كما هو لو غير مكتمل', () {
      expect(PhoneFormatter.display('01098'), '01098');
    });
  });
}
