import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package
import 'rewards_screen.dart';
import '../widgets/store_item.dart';
import '../firebase_auth.dart'; // Import your Firebase Auth Service
import '../helpers/sqflite_helper.dart'; // Import your DatabaseHelper
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform; // For Platform checks
import 'package:location/location.dart'; // For Location services

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
    requestPermissions();
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

  Future<void> requestPermissions() async {
    // Location permission (which you already have)
    await Permission.locationWhenInUse.request();

    // For Android 12+
    if (Platform.isAndroid) {
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
      // Also check if location services are enabled
      bool serviceEnabled = await Location().serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Location().requestService();
        if (!serviceEnabled) {
          print("Location services not enabled");
          return;
        }
      }
    }
  }

  // This function scans for our BLE beacon points - returns true/false if it's found
  Future<bool> scanForBeacon(String beaconId) async {
    bool isScanning = false;
    final completer = Completer<bool>();
    const int proximityThreshold = -72; // Approximate RSSI for 10-15 feet

    // Check if Bluetooth is powered on before scanning
    final bleStatus = await flutterReactiveBle.statusStream.firstWhere(
      (status) => status == BleStatus.ready,
      orElse: () => BleStatus.unknown,
    );

    if (bleStatus != BleStatus.ready) {
      print("Bluetooth is not powered on. Scan cannot proceed.");
      return false;
    }

    if (!isScanning) {
      isScanning = true;
      print("Starting BLE scan for beacon with UUID: $beaconId");

      StreamSubscription<DiscoveredDevice>? scanSubscription;
      Timer? timeoutTimer;

      // Set up the timeout to stop scanning after 5 seconds
      timeoutTimer = Timer(Duration(seconds: 5), () {
        if (isScanning) {
          scanSubscription?.cancel();
          isScanning = false;
          completer.complete(false);
        }
      });

      scanSubscription = flutterReactiveBle.scanForDevices(
        withServices: [],
      ).listen(
        (device) {
          if (device.id == beaconId) {
            print("Beacon found with UUID: $beaconId");

            // Check if the device is within the proximity threshold
            if (device.rssi >= proximityThreshold) {
              print(
                  "Beacon is within 10-15 feet. Current RSSI: ${device.rssi}");

              // Stop scanning and cancel the timeout timer
              scanSubscription?.cancel();
              timeoutTimer?.cancel();
              isScanning = false;
              completer.complete(
                  true); // Complete with true if both conditions are met
            } else {
              print(
                  "Beacon found, but please get closer. Current RSSI: ${device.rssi}");
            }
          }
        },
        onError: (error) {
          print("Error scanning for beacons: $error");

          // Cancel on error, stop the timer, and complete with false
          scanSubscription?.cancel();
          timeoutTimer?.cancel();
          isScanning = false;
          completer.complete(false);
        },
        onDone: () {
          print("Scan finished.");
          isScanning = false;
          timeoutTimer?.cancel();
        },
      );
    } else {
      print("A scan is already running.");
      return false;
    }

    // Wait until the completer completes with either true or false
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // List of store names
    final List<String> storeNames = [
      'Two Scoops Ice Cream & Waffles',
      'Delmarva Home Grown',
      'Blackwater Apothecary',
      'Breathe Interiors',
      'Rommel Center',
      'Store 6',
      'Store 7',
    ];

    // List of MAC address for the beacons on android
    final List<String> macAddr = [
      'D5:A4:AE:5C:DC:75',
      'C1:A2:64:3A:95:8F',
      'D5:8D:93:99:C9:BF',
      'D9:11:A6:6F:BC:00',
      'FC:DB:AC:C2:5F:DB',
      'nothingHere2',
      'nothingHere3',
    ];

    // List of device ID's for the beacons on iOS
    final List<String> iBKSids = [
      '9FCE50BD-9F68-6245-EC2D-37946CD12A1B',
      'B77DB3A4-2EBA-EA22-5066-D87D0A5E1526',
      '21A5BBAC-6A07-68ED-4EB8-69D806DE9781',
      'DB169B51-B331-4BAB-A719-9DD6087AAC06',
      '12E17224-877F-6EC5-1652-8C699316E86E',
      'noneId',
      'noneId',
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
                    mac: macAddr[index],
                    iBKS: iBKSids[index],
                    onCheckIn: () async {
                      if (Platform.isAndroid) {
                        print("Search using MAC address");
                        bool isFound = await scanForBeacon(macAddr[index]);

                        if (isFound) {
                          _addCoins(10);
                        } else {
                          print("Scan for beacon returned false");
                        }
                      } else if (Platform.isIOS) {
                        print("Search using device ID");
                        bool isFound = await scanForBeacon(iBKSids[index]);

                        if (isFound) {
                          _addCoins(10);
                        } else {
                          print("Scan for beacon returned false");
                        }
                      } else {
                        print("Incorrect OS");
                      }
                    },
                    color: itemColor,
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
