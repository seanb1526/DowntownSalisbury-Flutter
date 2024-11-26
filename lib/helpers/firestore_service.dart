import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch stores data from Firestore
  Future<List<Map<String, dynamic>>> getStoresData() async {
    try {
      // Fetch the stores collection
      QuerySnapshot querySnapshot = await _db.collection('Stores').get();

      // Convert Firestore documents into a list of Map data
      List<Map<String, dynamic>> storeList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return storeList;
    } catch (e) {
      print('Error fetching stores data: $e');
      return [];
    }
  }

  // Save redeemed coupon to Firestore
  Future<void> saveRedeemedCoupon({
    required String userId,
    required String type,
    required int discountPercentage,
    required DateTime purchaseDate,
    required DateTime expirationDate,
    required String couponCode,
  }) async {
    try {
      // Build the coupon data
      Map<String, dynamic> couponData = {
        'user_id': userId,
        'type': type,
        'discount_percentage': discountPercentage,
        'purchase_date': purchaseDate,
        'expiration_date': expirationDate,
        'coupon_code': couponCode,
        'accepted_date':
            FieldValue.serverTimestamp(), // Firestore server timestamp
      };

      // Add to RedeemedCoupons collection with auto-ID
      await _db.collection('RedeemedCoupons').add(couponData);

      print('Redeemed coupon successfully saved to Firestore.');
    } catch (e) {
      print('Error saving redeemed coupon: $e');
    }
  }

  // Initialize a new user in Firestore
  Future<void> initializeUser(String userId, String email) async {
    try {
      // Check if the user already exists to avoid overwriting data
      DocumentSnapshot userDoc =
          await _db.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        print('User already exists in Firestore.');
        return;
      }

      // Build the user data
      Map<String, dynamic> userData = {
        'email': email,
        'created_at':
            FieldValue.serverTimestamp(), // Firestore server timestamp
        'daily_activity': {}, // Placeholder for user's daily activity
      };

      // Save user to Firestore
      await _db.collection('Users').doc(userId).set(userData);

      print('New user initialized in Firestore.');
    } catch (e) {
      print('Error initializing user in Firestore: $e');
    }
  }
}
