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
}
