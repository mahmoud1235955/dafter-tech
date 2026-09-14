import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// يبعت رمز تأكيد SMS على الرقم (لازم يكون بصيغة E.164 مثل: `+2010...`).
  Future<void> sendOtp(String phone);

  /// يتحقق من الرمز عند Supabase ثم ينشئ/يحدّث الملف الشخصي.
  Future<UserModel> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  });

  /// يرجع المستخدم الحالي لو فيه جلسة سارية، غير كده `null`.
  Future<UserModel?> getCurrentUser();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.supabaseClient});

  static const String profilesTable = 'profiles';

  final SupabaseClient supabaseClient;

  @override
  Future<void> sendOtp(String phone) async {
    // shouldCreateUser: true → لو الرقم جديد يتم إنشاء حساب في auth.users
    await supabaseClient.auth.signInWithOtp(
      phone: phone,
      shouldCreateUser: true,
    );
  }

  @override
  Future<UserModel> verifyOtpAndRegister({
    required String phone,
    required String otp,
    required BusinessType businessType,
  }) async {
    final response = await supabaseClient.auth.verifyOTP(
      type: OtpType.sms,
      token: otp,
      phone: phone,
    );

    final authUser = response.user;

    if (authUser == null) {
      throw const AuthFlowException(
        'لم نتمكن من التأكد من الرمز، تأكد منه واطلب واحد جديد لو لزم الأمر',
      );
    }

    final userModel = UserModel(
      id: authUser.id,
      phone: authUser.phone?.isNotEmpty == true ? authUser.phone! : phone,
      businessType: businessType,
      createdAt: DateTime.tryParse(authUser.createdAt) ?? DateTime.now(),
    );

    // upsert علشان المستخدم القديم يحدّث بياناته بدل ما يخبط في تكرار
    await supabaseClient.from(profilesTable).upsert(userModel.toJson());

    return userModel;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final session = supabaseClient.auth.currentSession;
    final authUser = supabaseClient.auth.currentUser;

    if (session == null || authUser == null) return null;

    final row = await supabaseClient
        .from(profilesTable)
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (row == null) return null;

    return UserModel.fromJson(row);
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }
}
