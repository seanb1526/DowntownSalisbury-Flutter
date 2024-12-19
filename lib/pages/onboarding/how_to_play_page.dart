import 'package:flutter/material.dart';

class HowToPlayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "How to Play",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Use Image.asset to load the local image
          Image.asset(
            'assets/images/HowToPlay.jpeg',
            width: 300, // Set width if you want to control the image size
            height: 300, // Set height to control the image size
            fit: BoxFit
                .cover, // Optional: control how the image fits within the given space
          ),
          SizedBox(height: 16),
          Text("Go near beacons to scan them and earn points!"),
        ],
      ),
    );
  }
}
