import 'package:flutter/material.dart';

class RewardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String cost;
  final VoidCallback onRedeem;

  RewardItem({
    required this.icon,
    required this.title,
    required this.cost,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 4),
          Text(
            cost,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Expanded(child: Container()),
          ElevatedButton(
            onPressed: onRedeem,
            child: Text('Redeem'),
          ),
        ],
      ),
    );
  }
}
