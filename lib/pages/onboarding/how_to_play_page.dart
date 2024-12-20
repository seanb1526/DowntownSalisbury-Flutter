import 'package:flutter/material.dart';

class HowToPlayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Slim rectangle at the top
          Container(
            height: MediaQuery.of(context)
                .padding
                .top, // Height to account for the notch
            color: Color(0xFF019FDC), // Color for the rectangle
          ),
          SizedBox(height: 24), // Space below the rectangle
          // "How To Play" title
          Text(
            "How To Play",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24), // Space below the title
          // Center image
          Image.asset(
            'assets/images/HowToPlay.jpeg',
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 24), // Space below the image
          // Rules text
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Add padding on the sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Explore: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16, // Slightly larger font size
                        ),
                      ),
                      TextSpan(
                        text:
                            "Stroll through your Downtown and discover participating businesses\n",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16, // Slightly larger font size
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8), // Small space between rules
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Pulse: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16, // Slightly larger font size
                        ),
                      ),
                      TextSpan(
                        text:
                            "Use NavPulse to capture a store's Echo when you're in proximity\n",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16, // Slightly larger font size
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8), // Small space between rules
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Earn: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16, // Slightly larger font size
                        ),
                      ),
                      TextSpan(
                        text:
                            "Collect coins for each successful Pulse and redeem them in our rewards store.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16, // Slightly larger font size
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
