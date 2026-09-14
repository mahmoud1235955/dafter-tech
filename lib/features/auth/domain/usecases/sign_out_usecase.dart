import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// تسجيل الخروج: يمسح جلسة Supabase والنسخة المحلية.
class SignOutUseCase {
  final AuthRepository repository;

  const SignOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.signOut();
  }
}
