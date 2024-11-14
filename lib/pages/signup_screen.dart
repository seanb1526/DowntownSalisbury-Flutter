import 'package:flutter/material.dart';
import '../firebase_auth.dart'; // Import Firebase Auth Service
import 'login_screen.dart'; // Import LoginScreen
import 'beacon_home_screen.dart'; // Import BeaconHomeScreen
import 'package:downtown_salisbury/main.dart';
import '../helpers/sqflite_helper.dart'; // Import Database Helper
import '../helpers/firestore_service.dart'; // Import Firestore Service

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirestoreService _firestoreService =
      FirestoreService(); // Firestore Service

  Future<void> _signUp() async {
    final user = await _authService.signUp(
      _emailController.text,
      _passwordController.text,
    );

    if (user != null) {
      // 1. Get Firebase user ID upon successful signup
      String userId = user.uid;

      // 2. Initialize user currency balance in SQLite
      await DatabaseHelper().updateCurrency(userId, 0);

      // 3. Fetch store data from Firestore
      List<Map<String, dynamic>> storesData =
          await _firestoreService.getStoresData();

      // 4. Insert each store's data into SQLite Stores table
      for (var store in storesData) {
        // Add the user_id to each store data entry before inserting
        store['user_id'] = userId;
        await DatabaseHelper().insertStoreData(store);
      }

      print("Sign up successful: ${user.email}");

      // 5. Navigate to BeaconHomeScreen after setup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BeaconHomeScreen()),
      );
    } else {
      // Handle sign-up failure
      print("Sign up failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
