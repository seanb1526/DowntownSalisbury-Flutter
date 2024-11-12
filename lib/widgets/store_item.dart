import 'package:flutter/material.dart';

class StoreItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String isAvailable;
  final VoidCallback onCheckIn;
  final Color color; // Add this line
  final String mac; // store mac address of beacon for android
  final String iBKS; // store iBKS id for iOS

  StoreItem({
    required this.icon,
    required this.name,
    required this.isAvailable,
    required this.onCheckIn,
    required this.color, // Update this line
    required this.mac,
    required this.iBKS,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color, // Use the color parameter
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 4),
                Text(
                  isAvailable,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onCheckIn,
            child: Text('Check In'),
          ),
        ],
      ),
    );
  }
}
