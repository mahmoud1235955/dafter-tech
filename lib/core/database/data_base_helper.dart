import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // بنعمل Singleton علشان يكون عندنا نسخة واحدة شغالة في التطبيق كله
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // إنشاء الجداول وقت أول تشغيل للتطبيق
  Future<void> _createDB(Database db, int version) async {
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

  // إغلاق الداتابيز لما التطبيق يقفل
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
