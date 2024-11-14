import 'package:flutter/material.dart';
import '../firebase_auth.dart'; // Firebase Auth Service
import 'signup_screen.dart';
import 'package:downtown_salisbury/main.dart'; // MainScreen
import '../helpers/sqflite_helper.dart'; // DatabaseHelper
import '../helpers/firestore_service.dart'; // FirestoreService

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _login() async {
    final user = await _authService.logIn(
      _emailController.text,
      _passwordController.text,
    );

    if (user != null) {
      // Firebase UID (user's unique identifier)
      String userId = user.uid;

      // 1. Check if the user has a record in the SQLite currency table
      final existingBalance = await DatabaseHelper().getCurrency(userId);

      // If no currency record exists, initialize the user's currency to 0
      if (existingBalance == null) {
        await DatabaseHelper()
            .updateCurrency(userId, 0); // Initialize currency to 0
      }

      // 2. Check if the user has stores data in the SQLite Stores table
      final storeRecords = await DatabaseHelper().getStores();

      // If no store records exist, fetch from Firestore and insert into SQLite
      if (storeRecords.isEmpty) {
        // Fetch store data from Firestore
        List<Map<String, dynamic>> storesData =
            await _firestoreService.getStoresData();

        // Insert each store data entry into SQLite Stores table
        for (var store in storesData) {
          store['user_id'] =
              userId; // Associate each store entry with the current user
          await DatabaseHelper().insertStoreData(store);
        }
      } else {
        print("Stores SQLite table does exist, or we believe it does");
      }

      print("Login successful: ${user.email}");

      // Navigate to MainScreen with BeaconHomeScreen as the initial page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(initialIndex: 3), // Pass index
        ),
      );
    } else {
      // Handle login error (show a message to the user)
      print("Login failed");
      // Show error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the Main Screen
            Navigator.pop(context);
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
              onPressed: _login,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Sign Up screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
