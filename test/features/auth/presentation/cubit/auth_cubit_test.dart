import 'package:daftar_tech/core/errors/failures.dart';
import 'package:daftar_tech/core/utils/app_constants.dart';
import 'package:daftar_tech/features/auth/data/models/user_model.dart';
import 'package:daftar_tech/features/auth/domain/entities/user_entity.dart';
import 'package:daftar_tech/features/auth/domain/repositories/auth_repository.dart';
import 'package:daftar_tech/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:daftar_tech/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:daftar_tech/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:daftar_tech/features/auth/presentation/cubit/auth_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

/// نسخة وهمية من الـ repository لتشغيل الـ Cubit بدون شبكة أو قاعدة بيانات.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.sendOtpFailure, this.registerFailure});

  final Failure? sendOtpFailure;
  final Failure? registerFailure;

  final List<String> sentPhones = <String>[];
  final List<String> registerPhones = <String>[];

  @override
  Future<Either<Failure, Unit>> sendOtp(String phone) async {
    sentPhones.add(phone);
    if (sendOtpFailure != null) return Left(sendOtpFailure!);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  }) async {
    registerPhones.add(phone);
    if (registerFailure != null) return Left(registerFailure!);
    return Right(
      UserModel(
        id: 'usr_1',
        phone: phone,
        businessType: businessType,
        createdAt: DateTime(2024),
      ),
    );
  }
}

void main() {
  const validPhone = '01098765432';

  late FakeAuthRepository repository;
  late AuthCubit cubit;

  AuthCubit buildCubit(AuthRepository repo) => AuthCubit(
        registerUserUseCase: RegisterUserUseCase(repo),
        sendOtpUseCase: SendOtpUseCase(repo),
      );

  setUp(() {
    repository = FakeAuthRepository();
    cubit = buildCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('الحالة الابتدائية هي AuthInitial', () {
    expect(cubit.state, isA<AuthInitial>());
    expect(cubit.canResendOtp, isTrue);
  });

  test('sendOtp يرفض الرقم غير الصحيح بدون استدعاء الـ repository', () async {
    await cubit.sendOtp('01098');

    expect(cubit.state, isA<AuthOtpError>());
    expect(repository.sentPhones, isEmpty);
  });

  test('sendOtp يبعت الرقم بالصيغة الدولية ويبدأ العد التنازلي', () async {
    await cubit.sendOtp(validPhone);

    expect(repository.sentPhones, ['+201098765432']);
    expect(cubit.state, isA<AuthOtpSent>());
    expect(
      (cubit.state as AuthOtpSent).cooldown,
      AppConstants.otpResendCooldownSeconds,
    );
    expect(cubit.canResendOtp, isFalse);
  });

  test('sendOtp يمنع الإرسال المتكرر أثناء العد التنازلي', () async {
    await cubit.sendOtp(validPhone);
    await cubit.sendOtp(validPhone);

    expect(repository.sentPhones.length, 1);
  });

  test('sendOtp يرجع AuthOtpError عند فشل الإرسال', () async {
    final failingRepository = FakeAuthRepository(
      sendOtpFailure: const ServerFailure('فشل إرسال كود التأكيد'),
    );
    final failingCubit = buildCubit(failingRepository);
    addTearDown(failingCubit.close);

    await failingCubit.sendOtp(validPhone);

    expect(failingCubit.state, isA<AuthOtpError>());
    expect(failingCubit.canResendOtp, isTrue);
  });

  test('submitRegister يرجع AuthSuccess عند نجاح التحقق', () async {
    await cubit.submitRegister(
      phone: validPhone,
      otp: '4285',
      businessType: BusinessType.grocery,
    );

    expect(repository.registerPhones, ['+201098765432']);
    expect(cubit.state, isA<AuthSuccess>());
    expect((cubit.state as AuthSuccess).user.phone, '+201098765432');
  });

  test('submitRegister يرجع AuthError عند فشل التحقق', () async {
    final failingRepository = FakeAuthRepository(
      registerFailure: const ServerFailure('الرمز غير صحيح'),
    );
    final failingCubit = buildCubit(failingRepository);
    addTearDown(failingCubit.close);

    await failingCubit.submitRegister(
      phone: validPhone,
      otp: '0000',
      businessType: BusinessType.wholesaler,
    );

    expect(failingCubit.state, isA<AuthError>());
    expect((failingCubit.state as AuthError).message, 'الرمز غير صحيح');
  });
}
