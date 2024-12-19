import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import SVG package
import '../firebase_auth.dart'; // Firebase Auth Service
import 'signup_screen.dart';
import 'package:downtown_salisbury/main.dart'; // MainScreen
import '../helpers/sqflite_helper.dart'; // DatabaseHelper
import '../helpers/firestore_service.dart'; // FirestoreService

import 'onboarding_screen.dart'; // We can remove this once we finish desiging the onboarding pages

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
    try {
      final user = await _authService.logIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        String userId = user.uid;

        final existingBalance = await DatabaseHelper().getCurrency(userId);

        if (existingBalance == null) {
          await DatabaseHelper().updateCurrency(userId, 0);
        }

        final storeRecords = await DatabaseHelper().getStores();

        if (storeRecords.isEmpty) {
          List<Map<String, dynamic>> storesData =
              await _firestoreService.getStoresData();

          for (var store in storesData) {
            store['user_id'] = userId;
            await DatabaseHelper().insertStoreData(store);
          }
        }

        print("Login successful: ${user.email}");

        /* This is the original for the code underneath. It needs to go back once we finish onboarding pages
                Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(initialIndex: 3),
          ),
        );
        */

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(),
          ),
        );
      } else {
        _showErrorDialog('Login failed. Please try again.');
      }
    } catch (e) {
      print("Error during login: $e");
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 25, 36, 89), // Your RGBA color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              SvgPicture.asset(
                'assets/images/navpro.svg',
                height: 80, // Adjust size as needed
                width: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(252, 181, 85, 1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Log in to your account to continue.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(252, 181, 8, 1),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Color.fromRGBO(252, 181, 8, 1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F5F5), // Light background color
    );
  }
}
