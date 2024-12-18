import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Add padding to left and right
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Terms and Conditions",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "By proceeding, you agree to our Privacy Policy, Terms, and Code of Conduct.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to the next step or finish onboarding
              },
              child: Text("I Agree"),
            ),
          ],
        ),
      ),
    );
  }
}
