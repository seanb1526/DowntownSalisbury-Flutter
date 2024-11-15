import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

// Initialize the database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_currency.db');

    // Open the database and ensure tables are created if they do not exist
    var db = await openDatabase(path, readOnly: false);

    // Create the user_currency table if it doesn't exist
    await db.execute('''
    CREATE TABLE IF NOT EXISTS user_currency(
      user_id TEXT PRIMARY KEY, 
      currency_balance INTEGER
    )
  ''');

    // Create the Stores table if it doesn't exist
    await db.execute('''
    CREATE TABLE IF NOT EXISTS Stores (
      storeID INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT,
      icon TEXT,
      name TEXT,
      isAvailable TEXT,
      color TEXT,
      mac TEXT,
      iBKS TEXT,
      lastSuccessfulScanTime INTEGER DEFAULT 0,  -- Changed to INTEGER for milliseconds
      FOREIGN KEY (user_id) REFERENCES user_currency (user_id)
    )
  ''');

    return db;
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
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Replace if the store already exists
    );
  }

  Future<void> clearStores() async {
    final db = await database;
    await db.delete('stores'); // Clears all rows in the stores table
  }

  Future<void> insertOrUpdateStore(Map<String, dynamic> store) async {
    final db = await database;

    // Check if the store exists in the database
    final existingStore = await db.query(
      'Stores',
      where:
          'storeID = ?', // Replace 'id' with the actual unique identifier for your stores
      whereArgs: [store['id']], // Match against the unique store ID
    );

    if (existingStore.isEmpty) {
      // Insert a new record if the store does not exist
      await db.insert('stores', store);
    } else {
      // Update the existing record if the store already exists
      await db.update(
        'stores',
        store,
        where: 'id = ?', // Update the record that matches the store's ID
        whereArgs: [store['storeID']],
      );
    }
  }

  // Fetch store data from Firestore and insert it into SQLite
  Future<void> syncStoresFromFirestore(String userId) async {
    // Fetch data from Firestore
    final snapshot =
        await FirebaseFirestore.instance.collection('Stores').get();

    // Loop through each document in Firestore and insert it into SQLite
    for (var doc in snapshot.docs) {
      Map<String, dynamic> storeData = {
        'user_id': userId,
        'storeID': doc.id, // Firestore document ID as storeID
        'icon': doc['icon'] ?? '', // Default to empty string if no data
        'name': doc['name'] ?? '',
        'isAvailable': doc['isAvailable'] ??
            'available', // Default to 'true' if not available
        'color': doc['color'] ?? '',
        'mac': doc['mac'] ?? '',
        'iBKS': doc['iBKS'] ?? '',
        'lastSuccessfulScanTime': doc['lastSuccessfulScanTime'] ?? '',
      };

      // Insert the data into SQLite using insertStoreData
      await insertStoreData(storeData);
    }
  }

  // Get all stores
  Future<List<Map<String, dynamic>>> getStores() async {
    final db = await database;

    // Query the database
    List<Map<String, dynamic>> stores =
        await db.query('Stores'); // No filtering by user_id needed

    // Print the result to check what is returned
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
        'lastSuccessfulScanTime': lastScanTime, // Store the timestamp
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
}
