import '../../../../core/database/data_base_helper.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper databaseHelper;
  AuthLocalDataSourceImpl({required this.databaseHelper});
  @override
  Future<void> cacheUser(UserModel user) async {
    final db = await databaseHelper.database;
    await db.insert('users', user.toJson());
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final db = await databaseHelper.database;
    final res = await db.query('users', limit: 1);
    if (res.isNotEmpty) return UserModel.fromJson(res.first);
    return null;
  }
}
