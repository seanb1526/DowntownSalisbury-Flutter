import 'package:flutter/material.dart';
import 'rewards_screen.dart';
import '../widgets/store_item.dart';

class BeaconHomeScreen extends StatelessWidget {
  const BeaconHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of store names
    final List<String> storeNames = [
      'Two Scoops Ice Cream & Waffles',
      'Delmarva Home Grown',
      'Blackwater Apothecary',
      'Breathe Interiors',
      'Store 5',
      'Store 6',
      'Store 7',
    ];

    // List of colors for StoreItem
    final List<Color> storeItemColors = [
      Colors.green[100]!,
      Colors.red[100]!,
      Colors.blue[100]!,
      Colors.yellow[100]!,
      Colors.purple[100]!,
      Colors.orange[100]!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.camera_alt, size: 24),
            SizedBox(width: 8),
            Text('Downtown Game'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.wallet, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RewardsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              // Center the title
              child: Text(
                'Participating Stores',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount:
                    storeNames.length, // Use the length of the store names list
                itemBuilder: (context, index) {
                  // Alternate colors from the storeItemColors list
                  Color itemColor =
                      storeItemColors[index % storeItemColors.length];

                  return StoreItem(
                    icon: Icons.map_outlined,
                    name: storeNames[index], // Use the store name from the list
                    distance: (index % 2 == 0)
                        ? 'available'
                        : 'unavailable', // Example distance
                    onCheckIn: () {
                      // Add your check-in logic here
                    },
                    color: itemColor, // Pass the color
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on,
                        size: 24,
                        color:
                            Colors.amber[600]), // Change to a gold/yellow color
                    SizedBox(width: 8),
                    Text('1250 Coins'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RewardsScreen()),
                    );
                  },
                  child: Text('Spend Coins'),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
