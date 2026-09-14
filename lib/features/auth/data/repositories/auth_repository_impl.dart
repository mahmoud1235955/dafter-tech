import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/auth_error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Connectivity connectivity;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, Unit>> sendOtp(String phone) async {
    if (!await _isOnline()) return const Left(NetworkFailure());

    try {
      await remoteDataSource.sendOtp(phone);
      return const Right(unit);
    } catch (e) {
      return Left(mapAuthError(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  }) async {
    if (!await _isOnline()) return _offlineLogin(phone);

    try {
      final userModel = await remoteDataSource.verifyOtpAndRegister(
        phone: phone,
        otp: otp,
        businessType: businessType,
      );

      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } catch (e) {
      final failure = mapAuthError(e);

      // لو السبب شبكة وفيه حساب متخزن بنفس الرقم → ندخله أوفلاين
      if (failure is NetworkFailure) {
        final offline = await _offlineLogin(phone);
        if (offline.isRight()) return offline;
      }

      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    // 1. نجرب السحابة الأول (لو فيه جلسة سارية نحدّث النسخة المحلية)
    try {
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }
    } catch (_) {
      // مفيش نت أو الجلسة انتهت → نكمل بالنسخة المحلية
    }

    // 2. النسخة المحلية (تشغيل أوفلاين)
    try {
      return Right(await localDataSource.getCachedUser());
    } catch (_) {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remoteDataSource.signOut();
    } catch (_) {
      // لو مفيش نت سيب الجلسة تنتهي صلاحيتها لوحدها
    }

    try {
      await localDataSource.clearUser();
    } catch (_) {
      return const Left(DatabaseFailure());
    }

    return const Right(unit);
  }

  /// دخول أوفلاين: مسموح فقط لحساب متخزن محلياً بنفس الرقم.
  Future<Either<Failure, UserEntity>> _offlineLogin(String phone) async {
    try {
      final cached = await localDataSource.getCachedUser();

      if (cached != null &&
          PhoneFormatter.normalize(cached.phone) ==
              PhoneFormatter.normalize(phone)) {
        return Right(cached);
      }
    } catch (_) {
      return const Left(DatabaseFailure());
    }

    return const Left(
      NetworkFailure('محتاج اتصال بالإنترنت أول مرة علشان نفعّل رقمك'),
    );
  }

  Future<bool> _isOnline() async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
