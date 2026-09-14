import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // بنعمل Singleton علشان يكون عندنا نسخة واحدة شغالة في التطبيق كله
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // أي تغيير في الجداول يستدعي رفع النسخة + كتابة خطوة ترقية في _onUpgrade
  static const int databaseVersion = 2;

  DatabaseHelper._init();

  // الحصول على قاعدة البيانات أو إنشاؤها لو مش موجودة
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('daftar_tech.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // ترقية قاعدة البيانات للتطبيقات المثبتة قبل كده
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(_createUsersTableSql);
    }
  }

  // إنشاء الجداول وقت أول تشغيل للتطبيق
  Future<void> _createDB(Database db, int version) async {
    // 0. جدول المستخدم (بيانات الحساب بعد تسجيل الدخول)
    await db.execute(_createUsersTableSql);

    // 1. جدول العملاء
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT,
        totalDebt REAL NOT NULL DEFAULT 0.0,
        creditLimit REAL NOT NULL DEFAULT 0.0,
        lastTransactionAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. جدول المعاملات (الفواتير والسداد)
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        paymentMethod INTEGER NOT NULL,
        notes TEXT,
        receiptImageUrl TEXT,
        bankReferenceNumber TEXT,
        transactionDate TEXT NOT NULL,
        isVerified INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');
  }

  // 0. جدول المستخدمين: نفس أعمدة UserModel.toJson
  static const String _createUsersTableSql = '''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        phone TEXT NOT NULL,
        business_type INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''';

  // إغلاق الداتابيز لما التطبيق يقفل
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
