import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_currency.db');
    return await openDatabase(
      path,
      version:
          1, // Increment version to force table creation for the stores table
      onCreate: (db, version) async {
        // Create the user_currency table
        await db.execute(
          'CREATE TABLE user_currency(user_id TEXT PRIMARY KEY, currency_balance INTEGER)',
        );
      },
    );
  }

  // Insert or update user currency
  Future<void> updateCurrency(String userId, int balance) async {
    final db = await database;
    await db.insert(
      'user_currency',
      {'user_id': userId, 'currency_balance': balance},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get user currency balance
  Future<int?> getCurrency(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'user_currency',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first['currency_balance'] as int?;
    }
    return null;
  }
}
