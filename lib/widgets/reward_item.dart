import 'package:flutter/material.dart';

class RewardItem extends StatelessWidget {
  final String imagePath; // Changed from 'icon' to 'imagePath'
  final String title;
  final String cost;
  final VoidCallback onRedeem;

  RewardItem({
    required this.imagePath, // Accepts the image path as a parameter
    required this.title,
    required this.cost,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(
            255, 95, 194, 240), // Light blue background color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center content horizontally
        children: [
          // Replace the Icon with Image.asset
          Image.asset(
            imagePath, // Use the imagePath provided
            width:
                100.0, // Adjust the width of the image (you can change this value)
            height:
                50.0, // Adjust the height of the image (you can change this value)
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center, // Center the title text
          ),
          SizedBox(height: 4),
          Text(
            cost,
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center, // Center the cost text
          ),
          // ElevatedButton with updated style
          ElevatedButton(
            onPressed: onRedeem,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Button background color
              foregroundColor: Colors.blue, // Button text color
            ),
            child: Text('Redeem'),
          ),
        ],
      ),
    );
  }
}
