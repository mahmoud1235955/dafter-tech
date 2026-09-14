import 'package:sqflite/sqflite.dart';

import '../../../../core/database/data_base_helper.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);

  Future<UserModel?> getCachedUser();

  /// مسح الحساب المحلي (تسجيل الخروج).
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({required this.databaseHelper});

  static const String usersTable = 'users';

  final DatabaseHelper databaseHelper;

  @override
  Future<void> cacheUser(UserModel user) async {
    final db = await databaseHelper.database;

    // replace: لو نفس المستخدم اتسجل تاني نحدّث صفه بدل ما نرمي خطأ تكرار
    await db.insert(
      usersTable,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final db = await databaseHelper.database;
    final res = await db.query(usersTable, limit: 1);

    if (res.isEmpty) return null;

    return UserModel.fromJson(res.first);
  }

  @override
  Future<void> clearUser() async {
    final db = await databaseHelper.database;
    await db.delete(usersTable);
  }
}
