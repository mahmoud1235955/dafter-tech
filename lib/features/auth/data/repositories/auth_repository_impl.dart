import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

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
    try {
      await remoteDataSource.sendOtp(phone);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('فشل إرسال كود التأكيد'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      // تجربة التسجيل السحابي أولاً لو فيه إنترنت
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        final userModel = await remoteDataSource.verifyOtpAndRegister(
          phone: phone,
          otp: otp,
          businessType: businessType,
        );
        await localDataSource.cacheUser(userModel);
        return Right(userModel);
      } else {
        // إنشاء الحساب محلياً فوراً لدعم الـ Offline-First
        final localUser = UserModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          phone: phone,
          businessType: businessType,
          createdAt: DateTime.now(),
        );
        await localDataSource.cacheUser(localUser);
        return Right(localUser);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
