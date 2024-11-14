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
}
