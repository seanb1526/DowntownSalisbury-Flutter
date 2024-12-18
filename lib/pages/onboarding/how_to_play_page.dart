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
          // Add your graphics or instructions here
          Icon(Icons.bluetooth_searching, size: 100, color: Colors.blue),
          Text("Go near beacons to scan them and earn points!"),
        ],
      ),
    );
  }
}
