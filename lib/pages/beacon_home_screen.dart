import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'rewards_screen.dart';
import '../widgets/store_item.dart';
import '../firebase_auth.dart';
import '../helpers/sqflite_helper.dart';

class BeaconHomeScreen extends StatefulWidget {
  const BeaconHomeScreen({super.key});

  @override
  _BeaconHomeScreenState createState() => _BeaconHomeScreenState();
}

class _BeaconHomeScreenState extends State<BeaconHomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  int _coinBalance = 0;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _fetchCoinBalance();
    requestPermissions();
  }

  @override
  void dispose() {
    // Make sure to stop scanning when disposing
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    // Request necessary permissions on Android
    if (Platform.isAndroid) {
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
      await Permission.locationWhenInUse.request();
    }

    // Check if Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not available");
      return;
    }

    // Check if Bluetooth is on
    BluetoothAdapterState bluetoothState =
        await FlutterBluePlus.adapterState.first;
    if (bluetoothState != BluetoothAdapterState.on) {
      print("Bluetooth is off");
      // On Android, this will open Bluetooth settings
      // On iOS, this will show a "Please turn on Bluetooth" dialog
      await FlutterBluePlus.turnOn();
    } else {
      print("Bluetooth is already on");
    }
  }

  Future<void> _fetchCoinBalance() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final balance = await DatabaseHelper().getCurrency(user.uid);
      setState(() {
        _coinBalance = balance ?? 0;
      });
    }
  }

  Future<void> _addCoins(int coinsToAdd) async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final currentBalance = await DatabaseHelper().getCurrency(user.uid) ?? 0;
      final newBalance = currentBalance + coinsToAdd;
      await DatabaseHelper().updateCurrency(user.uid, newBalance);
      setState(() {
        _coinBalance = newBalance;
      });
    }
  }

  Future<void> scanForBeacon(String beaconId) async {
    if (isScanning) {
      print("Already scanning");
      return;
    }

    setState(() {
      isScanning = true;
    });

    print("Starting scan for beacon: $beaconId");

    try {
      // Start scanning
      FlutterBluePlus.scanResults.listen(
        (results) {
          for (ScanResult r in results) {
            print(
                '${r.device.remoteId}: "${r.device.platformName}" found! rssi: ${r.rssi}, advertisementData: ${r.advertisementData.manufacturerData}');

            // Check if this is our target beacon
            if (r.device.remoteId.toString() == beaconId ||
                r.device.platformName.contains(beaconId)) {
              print("Found matching beacon!");
              FlutterBluePlus.stopScan();
              setState(() {
                isScanning = false;
              });
              _addCoins(10); // Add coins when beacon is found
              return;
            }
          }
        },
        onError: (e) {
          print("Scan error: $e");
          setState(() {
            isScanning = false;
          });
        },
      );

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      print("Error starting scan: $e");
      setState(() {
        isScanning = false;
      });
    }

    // After timeout
    setState(() {
      isScanning = false;
    });
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
                      scanForBeacon(beaconNames[index]);
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
