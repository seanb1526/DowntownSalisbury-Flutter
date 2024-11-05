import 'package:flutter/material.dart';
import '../firebase_auth.dart'; // Import your Firebase Auth Service
import 'login_screen.dart'; // Import your LoginScreen
import 'beacon_home_screen.dart'; // Import your BeaconHomeScreen
import 'package:downtown_salisbury/main.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp() async {
    final user = await _authService.signUp(
      _emailController.text,
      _passwordController.text,
    );
    if (user != null) {
      // Automatically log in the user and navigate to BeaconHomeScreen
      print("Sign up successful: ${user.email}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BeaconHomeScreen()),
      );
    } else {
      // Handle sign-up error (show a message to the user)
      print("Sign up failed");
      // You can show a SnackBar or AlertDialog to inform the user about the error
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
            // Navigate back to Main Screen
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
                // Navigate to Login screen
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
