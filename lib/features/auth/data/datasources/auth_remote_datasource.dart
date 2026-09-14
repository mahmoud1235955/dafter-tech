import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phone);
  Future<UserModel> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> sendOtp(String phone) async {
    // إرسال كود OTP عبر Supabase Auth
    await supabaseClient.auth.signInWithOtp(phone: phone);
  }

  @override
  Future<UserModel> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  }) async {
    final userId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final userModel = UserModel(
      id: userId,
      phone: phone,
      businessType: businessType,
      createdAt: DateTime.now(),
    );

    await supabaseClient.from('profiles').insert(userModel.toJson());

    return userModel;
  }
}
