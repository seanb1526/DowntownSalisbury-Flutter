import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Column(
        children: [
          // Slim rectangle for top padding
          Container(
            height: MediaQuery.of(context)
                .padding
                .top, // Height to account for the notch
            color: Color(0xFF019FDC), // Color for the rectangle
          ),
          SizedBox(height: 80), // Added space between rectangle and logo
          // Logo centered at the top
          Center(
            child: Image.asset(
              'assets/images/navpulse.png',
              height: 120, // Adjust height as needed
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 24), // More space between the logo and the text
          // Headline text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  "Step into Rewards with NavPulse",
                  style: TextStyle(
                    fontSize: 20, // Slightly larger text
                    fontWeight: FontWeight.w600, // Semi-bold
                    color: Color(0xFF281D6D), // Your specified color
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                // Description text
                Text(
                  "Scan beacons, earn points, and redeem rewards.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
