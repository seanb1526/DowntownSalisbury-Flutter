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
          2, // Increment version to force table creation for the `stores` table
      onCreate: (db, version) async {
        // Create the user_currency table
        await db.execute(
          'CREATE TABLE user_currency(user_id TEXT PRIMARY KEY, currency_balance INTEGER)',
        );

        // Create the stores table with `is_available` defaulting to true (1)
        await db.execute(
          'CREATE TABLE stores(store_id INTEGER PRIMARY KEY AUTOINCREMENT, store_name TEXT, beacon_id TEXT, is_available INTEGER DEFAULT 1)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Add the stores table if upgrading from version 1
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE stores(store_id INTEGER PRIMARY KEY AUTOINCREMENT, store_name TEXT, beacon_id TEXT, is_available INTEGER DEFAULT 1)',
          );
        }
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

  // Insert store data
  Future<void> insertStore(String storeName, String beaconId,
      {bool isAvailable = true}) async {
    final db = await database;
    await db.insert(
      'stores',
      {
        'store_name': storeName,
        'beacon_id': beaconId,
        'is_available': isAvailable ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all stores
  Future<List<Map<String, dynamic>>> getAllStores() async {
    final db = await database;
    return await db.query('stores');
  }

  // Update availability of a store
  Future<void> updateStoreAvailability(
      String beaconId, bool isAvailable) async {
    final db = await database;
    await db.update(
      'stores',
      {'is_available': isAvailable ? 1 : 0},
      where: 'beacon_id = ?',
      whereArgs: [beaconId],
    );
  }

  // Get store by beacon ID
  Future<Map<String, dynamic>?> getStoreByBeaconId(String beaconId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'stores',
      where: 'beacon_id = ?',
      whereArgs: [beaconId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
