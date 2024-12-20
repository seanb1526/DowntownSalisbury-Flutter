import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  // Get current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e); // Handle errors appropriately
      return null;
    }
  }

  // Log In
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e); // Handle errors appropriately
      return null;
    }
  }

  // Log Out
  Future<void> logOut() async {
    print("Logging out..."); // Debugging log
    await _auth.signOut();
    print("Logged out successfully");
    // Check if the user is logged out
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print(
          "No user is currently logged in."); // Should show this if logged out
    } else {
      print("User is still logged in: ${currentUser.email}");
    }
  }
}
