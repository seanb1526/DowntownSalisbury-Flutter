import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;

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

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_rewards.db');

    var db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // User Currency Table
    await db.execute('''
    CREATE TABLE user_currency(
      user_id TEXT PRIMARY KEY, 
      currency_balance INTEGER
    )
    ''');

    // Stores Table
    await db.execute('''
    CREATE TABLE Stores (
      storeID INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT,
      icon TEXT,
      name TEXT,
      isAvailable TEXT,
      color TEXT,
      mac TEXT,
      iBKS TEXT,
      lastSuccessfulScanTime INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES user_currency (user_id)
    )
    ''');

    // Coupons Table
    await db.execute('''
    CREATE TABLE Coupons (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT,
      type TEXT,
      discount_percentage INTEGER,
      purchase_date INTEGER,
      expiration_date INTEGER,
      coupon_code TEXT,
      FOREIGN KEY (user_id) REFERENCES user_currency (user_id)
    )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add coupon table if upgrading from version 1
      await db.execute('''
      CREATE TABLE Coupons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        type TEXT,
        discount_percentage INTEGER,
        purchase_date INTEGER,
        expiration_date INTEGER,
        coupon_code TEXT,
        FOREIGN KEY (user_id) REFERENCES user_currency (user_id)
      )
      ''');
    }
  }

  // Coupon-related methods
  Future<int> purchaseCoupon(
      String userId, String type, int discountPercentage) async {
    final db = await database;

    // Generate a unique coupon code
    String couponCode = _generateCouponCode();

    // Current timestamp
    int now = DateTime.now().millisecondsSinceEpoch;

    // Coupon expires in 30 days
    int expirationDate = now + (30 * 24 * 60 * 60 * 1000);

    return await db.insert('Coupons', {
      'user_id': userId,
      'type': type,
      'discount_percentage': discountPercentage,
      'purchase_date': now,
      'expiration_date': expirationDate,
      'coupon_code': couponCode
    });
  }

  Future<List<Map<String, dynamic>>> getUserCoupons(String userId) async {
    final db = await database;
    return await db.query(
      'Coupons',
      where: 'user_id = ? AND expiration_date > ?',
      whereArgs: [userId, DateTime.now().millisecondsSinceEpoch],
    );
  }

  String _generateCouponCode() {
    // Simple coupon code generation
    return DateTime.now().millisecondsSinceEpoch.toString().substring(5, 12);
  }

  // Method to delete a coupon
  Future<void> deleteCoupon(String userId, String couponCode) async {
    final db = await database;
    await db.delete(
      'Coupons', // Table name
      where:
          'user_id = ? AND coupon_code = ?', // Assuming user_id and coupon_code are unique
      whereArgs: [userId, couponCode],
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

  // Insert store data dynamically into SQLite
  Future<void> insertStoreData(Map<String, dynamic> storeData) async {
    final db = await database;
    await db.insert(
      'Stores',
      storeData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearStores() async {
    final db = await database;
    await db.delete('stores');
  }

  Future<void> insertOrUpdateStore(Map<String, dynamic> store) async {
    final db = await database;

    final existingStore = await db.query(
      'Stores',
      where: 'storeID = ?',
      whereArgs: [store['id']],
    );

    if (existingStore.isEmpty) {
      await db.insert('stores', store);
    } else {
      await db.update(
        'stores',
        store,
        where: 'id = ?',
        whereArgs: [store['storeID']],
      );
    }
  }

  // Fetch store data from Firestore and insert it into SQLite
  Future<void> syncStoresFromFirestore(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Stores').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> storeData = {
        'user_id': userId,
        'storeID': doc.id,
        'icon': doc['icon'] ?? '',
        'name': doc['name'] ?? '',
        'isAvailable': doc['isAvailable'] ?? 'available',
        'color': doc['color'] ?? '',
        'mac': doc['mac'] ?? '',
        'iBKS': doc['iBKS'] ?? '',
        'lastSuccessfulScanTime': doc['lastSuccessfulScanTime'] ?? '',
      };

      await insertStoreData(storeData);
    }
  }

  // Get all stores
  Future<List<Map<String, dynamic>>> getStores() async {
    final db = await database;
    List<Map<String, dynamic>> stores = await db.query('Stores');
    print('Stores retrieved: $stores');
    return stores;
  }

  // Update store availability for a specific store
  Future<void> updateStoreAvailability(
      int storeId, String availability, int lastScanTime) async {
    final db = await database;

    await db.update(
      'stores',
      {
        'isAvailable': availability,
        'lastSuccessfulScanTime': lastScanTime,
      },
      where: 'storeID = ?',
      whereArgs: [storeId],
    );
  }

  // Update the last successful scan time for a store
  Future<void> updateLastSuccessfulScanTime(int storeId, int timestamp) async {
    final db = await database;

    await db.update(
      'stores',
      {
        'lastSuccessfulScanTime': timestamp,
      },
      where: 'storeID = ?',
      whereArgs: [storeId],
    );
  }

  Future<Map<String, dynamic>?> getStoreByField(
      String columnToQuery, String beaconId) async {
    try {
      // Use DatabaseHelper to get the database instance
      final db = await DatabaseHelper().database;

      // Query the 'Stores' table to find the store by the specified column and beaconId
      final List<Map<String, dynamic>> result = await db.query(
        'Stores', // The table to query
        where: '$columnToQuery = ?', // Query the specific column (mac or iBKS)
        whereArgs: [beaconId], // Use beaconId as the query argument
      );

      if (result.isNotEmpty) {
        return result.first; // Return the first result as store data
      } else {
        print('No store found for beaconId: $beaconId');
        return null; // Return null if no store was found
      }
    } catch (e) {
      print('Error querying store by $columnToQuery: $e');
      return null; // Return null if there was an error
    }
  }

  Future<Map<String, dynamic>?> getStoreByBeacon(String beaconId) async {
    try {
      // Check the platform using dart:io's Platform class
      String columnToQuery =
          ''; // Determine which column to query (mac or iBKS)

      if (Platform.isIOS) {
        columnToQuery = 'iBKS'; // iOS uses iBKS field
      } else if (Platform.isAndroid) {
        columnToQuery = 'mac'; // Android uses mac field
      } else {
        print('Unsupported platform');
        return null; // In case of unsupported platform
      }

      // Query the database based on the platform-specific column
      final store =
          await DatabaseHelper().getStoreByField(columnToQuery, beaconId);

      return store; // Return the store data if found, or null if not
    } catch (e) {
      print('Error fetching store by beacon: $e');
      return null; // Return null in case of an error
    }
  }
}
