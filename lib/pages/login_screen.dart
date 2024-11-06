import 'package:flutter/material.dart';
import '../firebase_auth.dart'; // Import your Firebase Auth Service
import 'signup_screen.dart';
import 'beacon_home_screen.dart'; // Import your BeaconHomeScreen
import 'package:downtown_salisbury/main.dart'; // Import your MainScreen
import '../helpers/sqflite_helper.dart'; // Import your DatabaseHelper

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final user = await _authService.logIn(
      _emailController.text,
      _passwordController.text,
    );
    if (user != null) {
      // Firebase UID (user's unique identifier)
      String userId = user.uid;

      // Check if the user has a record in the SQLite database
      final existingBalance = await DatabaseHelper().getCurrency(userId);

      // If no record exists, initialize the user's data with a balance of 0
      if (existingBalance == null) {
        await DatabaseHelper()
            .updateCurrency(userId, 0); // Initialize currency to 0
      }

      print("Login successful: ${user.email}");

      // Navigate to MainScreen with BeaconHomeScreen as the initial page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(initialIndex: 3)), // Pass index
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
