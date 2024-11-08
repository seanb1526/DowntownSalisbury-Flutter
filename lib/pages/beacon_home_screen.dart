import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package
import 'rewards_screen.dart';
import '../widgets/store_item.dart';
import '../firebase_auth.dart'; // Import your Firebase Auth Service
import '../helpers/sqflite_helper.dart'; // Import your DatabaseHelper
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

final flutterReactiveBle = FlutterReactiveBle();

class BeaconHomeScreen extends StatefulWidget {
  const BeaconHomeScreen({super.key});

  @override
  _BeaconHomeScreenState createState() => _BeaconHomeScreenState();
}

class _BeaconHomeScreenState extends State<BeaconHomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  int _coinBalance = 0; // Store user's coin balance

  @override
  void initState() {
    super.initState();
    _fetchCoinBalance();
    requestLocationPermission();
  }

  // Fetch the user's coin balance from the database
  Future<void> _fetchCoinBalance() async {
    final user = await _authService.getCurrentUser(); // Get the current user
    if (user != null) {
      final userId = user.uid; // Get the Firebase user ID
      final balance = await DatabaseHelper().getCurrency(userId);
      setState(() {
        _coinBalance = balance ?? 0; // Set balance or default to 0 if not found
      });
    }
  }

  // Update the user's coin balance when they check in
  Future<void> _addCoins(int coinsToAdd) async {
    final user = await _authService.getCurrentUser(); // Get the current user
    if (user != null) {
      final userId = user.uid; // Get the Firebase user ID
      final currentBalance = await DatabaseHelper().getCurrency(userId) ?? 0;
      final newBalance = currentBalance + coinsToAdd;

      // Update the coin balance in the database
      await DatabaseHelper().updateCurrency(userId, newBalance);

      // Update the UI with the new balance
      setState(() {
        _coinBalance = newBalance;
      });
    }
  }

  Future<void> requestLocationPermission() async {
    // Request the location permission
    var status = await Permission.locationWhenInUse.request();

    // Check if the permission is granted
    if (status.isGranted) {
      print("Location permission granted.");
    } else {
      print("Location permission not granted.");
    }
  }

  Future<void> scanForBeacon(String beaconId) async {
    // Request location permission before proceeding
    await requestLocationPermission();

    // Check if location permission is granted
    if (await Permission.locationWhenInUse.isGranted) {
      print("Starting BLE scan for beacon with UUID: $beaconId");

      // Ensure no other scan is running by cancelling previous scan subscription
      StreamSubscription<DiscoveredDevice>? scanSubscription;

      // Start scanning for devices
      scanSubscription = flutterReactiveBle.scanForDevices(
        withServices: [], // We don't filter by service here, we want all devices
      ).listen(
        (device) {
          print("Found device: ${device.id}, name: ${device.name}");

          // Check if this is the beacon we are looking for
          if (device.id == beaconId) {
            // Beacon with the desired UUID found
            print("Beacon found with UUID: $beaconId");

            // Stop scanning for beacons
            scanSubscription?.cancel();
          }
        },
        onError: (error) {
          print("Error scanning for beacons: $error");

          // Cancel the scan on error as well
          scanSubscription?.cancel();
        },
        onDone: () {
          print("Scan finished.");
        },
      );
    } else {
      // If location permission is not granted, print a message
      print("Location permission not granted, scan cannot proceed.");
    }
  }

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

    // List of DeviceNames for the beacons
    final List<String> beaconNames = [
      '9FCE50BD-9F68-6245-EC2D-37946CD12A1B',
      '7369744756d736974756d736974756d15',
      'D5:A4:AE:5C:DC:75',
      'IndoorNavPRO 2s',
      '736974475-6d73-6974-756d-736974756d15',
      'IndoorNavPRO 6',
      'IndoorNavPRO 7',
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
            SvgPicture.asset(
              'assets/images/navpro.svg', // Path to your SVG asset
              height: 24, // Set the height you want
              width: 24, // Set the width you want
            ),
            SizedBox(width: 8),
            Text('Downtown Game'),
          ],
        ),
        automaticallyImplyLeading: false, // This will hide the back arrow
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 24),
            onPressed: () async {
              // Log out the user and print debug info
              await _authService.logOut();

              // Verify the user is logged out
              bool loggedIn = await _authService.isLoggedIn();
              print(
                  "Is user logged in after logout? $loggedIn"); // Should print false

              // Navigate back to the MainScreen (with BottomNav)
              Navigator.pushReplacementNamed(
                  context, '/'); // Using the '/' for main screen with BottomNav
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
              child: Text(
                'Participating Stores',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: storeNames.length,
                itemBuilder: (context, index) {
                  Color itemColor =
                      storeItemColors[index % storeItemColors.length];

                  return StoreItem(
                    icon: Icons.map_outlined,
                    name: storeNames[index],
                    isAvailable: (index % 2 == 0) ? 'available' : 'unavailable',
                    onCheckIn: () async {
                      // Attempt to scan for the beacon when checking in
                      await scanForBeacon(beaconNames[index]);

                      // If the beacon is found, add 10 coins
                      _addCoins(10);
                    },
                    color: itemColor,
                    beaconID: beaconNames[index],
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
                        size: 24, color: Colors.amber[600]),
                    SizedBox(width: 8),
                    Text(
                      '$_coinBalance Coins',
                      style: TextStyle(fontSize: 18),
                    ), // Display user's balance
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to RewardsScreen and wait for result
                    final updatedBalance = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RewardsScreen()),
                    );

                    // Check if the updated balance is not null and refresh the coin balance
                    if (updatedBalance != null &&
                        updatedBalance != _coinBalance) {
                      setState(() {
                        _coinBalance =
                            updatedBalance; // Update coin balance if it's changed
                      });
                    }
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
