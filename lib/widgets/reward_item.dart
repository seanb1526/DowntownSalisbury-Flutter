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
      decoration: BoxDecoration(
        color: const Color.fromARGB(
            255, 136, 207, 240), // Light blue background color
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
                60.0, // Adjust the height of the image (you can change this value)
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold, // Makes the text bold
                ),
            textAlign: TextAlign.center, // Center the title text
          ),
          SizedBox(height: 4),
          Text(
            cost,
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
            textAlign: TextAlign.center, // Center the cost text
          ),
          SizedBox(height: 4),
          // ElevatedButton with updated style
          ElevatedButton(
            onPressed: onRedeem,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Button background color
              foregroundColor:
                  const Color.fromARGB(255, 0, 0, 0), // Button text color
              elevation: 10, // Add elevation to create a shadow
            ),
            child: Text('Redeem'),
          )
        ],
      ),
    );
  }
}
