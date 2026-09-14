import 'package:daftar_tech/features/auth/presentation/cubit/uth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/register_user_usecase.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUserUseCase registerUserUseCase;

  AuthCubit({required this.registerUserUseCase}) : super(AuthInitial());

  Future<void> requestOtp(String phone) async {
    // يمكن إضافة منطق طلب الـ OTP هنا عند الحاجة
  }

  Future<void> submitRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  }) async {
    emit(AuthLoading());

    final result = await registerUserUseCase(
      phone: phone,
      otp: otp,
      businessType: businessType,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
