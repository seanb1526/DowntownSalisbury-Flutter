import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import SVG package
import '../firebase_auth.dart'; // Firebase Auth Service
import 'login_screen.dart'; // LoginScreen
import 'package:downtown_salisbury/main.dart'; // MainScreen
import '../helpers/sqflite_helper.dart'; // DatabaseHelper
import '../helpers/firestore_service.dart'; // FirestoreService

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _signUp() async {
    try {
      final user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        String userId = user.uid;

        // Initialize user's in-app currency balance in local database
        await DatabaseHelper().updateCurrency(userId, 0);

        // Clear and populate local stores database with data from Firestore
        await DatabaseHelper().clearStores();
        List<Map<String, dynamic>> storesData =
            await _firestoreService.getStoresData();

        for (var store in storesData) {
          store['user_id'] = userId;
          await DatabaseHelper().insertOrUpdateStore(store);
        }

        // Initialize the user in Firestore
        await _firestoreService.initializeUser(userId, user.email!);

        print("Sign up successful: ${user.email}");

        // Navigate to the main screen after successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(initialIndex: 3),
          ),
        );
      } else {
        _showErrorDialog('Sign up failed. Please try again.');
      }
    } catch (e) {
      print("Error during sign up: $e");
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
          'Sign Up',
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
                'Create Your Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(252, 181, 85, 1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Sign up to start exploring and earning rewards!',
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
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(252, 181, 8, 1),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Already have an account? Log In',
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
