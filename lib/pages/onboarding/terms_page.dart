import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width *
        0.8; // 80% of screen width for the buttons

    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center the content
        children: [
          // Slim rectangle at the top to account for the notch
          Container(
            height: MediaQuery.of(context).padding.top, // Height for the notch
            color: Color(0xFF019FDC), // Color for the rectangle
          ),
          SizedBox(height: 16), // Space after the rectangle

          // NavPulse image at the top middle
          Center(
            child: Image.asset(
              'assets/images/navpulse.png',
              height: 120, // Adjust height as needed
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 24), // Space between the rectangle and the image

          // Text: Please review the following
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Please review the following:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30), // Space under the text

          // Vertical Stack of Buttons
          Column(
            children: [
              // Privacy Policy Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: buttonWidth, // Set the width of the button
                  child: ElevatedButton(
                    onPressed: () {
                      // Action for Privacy Policy
                    },
                    child: Text("Privacy Policy"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF732E99), // Button color
                      foregroundColor: Colors.white, // Text color
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ),
              ),
              // Terms of Service Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: buttonWidth, // Set the width of the button
                  child: ElevatedButton(
                    onPressed: () {
                      // Action for Terms of Service
                    },
                    child: Text("Terms of Service"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF732E99), // Button color
                      foregroundColor: Colors.white, // Text color
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ),
              ),
              // Code of Conduct Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: buttonWidth, // Set the width of the button
                  child: ElevatedButton(
                    onPressed: () {
                      // Action for Code of Conduct
                    },
                    child: Text("Code of Conduct"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF732E99), // Button color
                      foregroundColor: Colors.white, // Text color
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 30), // Space after buttons

          // Text: Agreement Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "By proceeding, you agree that you have read our Privacy Policy and Terms of Service, and agree to play safely!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
