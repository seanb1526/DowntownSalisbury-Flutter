import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'rewards_screen.dart';
import '../widgets/store_item.dart';
import '../firebase_auth.dart';
import '../helpers/sqflite_helper.dart';
import '../helpers/firestore_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:location/location.dart';
import './acquired_rewards_screen.dart';

final flutterReactiveBle = FlutterReactiveBle();

class BeaconHomeScreen extends StatefulWidget {
  const BeaconHomeScreen({super.key});

  @override
  _BeaconHomeScreenState createState() => _BeaconHomeScreenState();
}

class _BeaconHomeScreenState extends State<BeaconHomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int _coinBalance = 0;
  List<Map<String, dynamic>> _stores =
      []; // List to hold store data from the database

  @override
  void initState() {
    super.initState();
    _fetchCoinBalance();
    _fetchStores();
    requestPermissions();
  }

  Future<void> _fetchCoinBalance() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final userId = user.uid;
      final balance = await DatabaseHelper().getCurrency(userId);
      setState(() {
        _coinBalance = balance ?? 0;
      });
    }
  }

  Future<void> _fetchStores() async {
    setState(() {
      _stores.clear(); // Clear the list before fetching new data
    });

    final fetchedStores = await DatabaseHelper().getStores(); // Fetch new data
    setState(() {
      _stores = fetchedStores;
    });
  }

  Future<void> _addCoins(int coinsToAdd) async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final userId = user.uid;
      final currentBalance = await DatabaseHelper().getCurrency(userId) ?? 0;
      final newBalance = currentBalance + coinsToAdd;
      await DatabaseHelper().updateCurrency(userId, newBalance);
      setState(() {
        _coinBalance = newBalance;
      });
    }
  }

  Future<void> requestPermissions() async {
    await Permission.locationWhenInUse.request();
    if (Platform.isAndroid) {
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
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

  Future<bool> scanForBeacon(String beaconId) async {
    bool isScanning = false;
    final completer = Completer<bool>();
    const int proximityThreshold = -72;

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

      timeoutTimer = Timer(Duration(seconds: 5), () {
        if (isScanning) {
          scanSubscription?.cancel();
          isScanning = false;
          completer.complete(false);
        }
      });

      // Modified beacon scanning code
      scanSubscription = flutterReactiveBle.scanForDevices(
        withServices: [],
      ).listen(
        (device) async {
          if (device.id == beaconId) {
            print("Beacon found with UUID: $beaconId");
            if (device.rssi >= proximityThreshold) {
              print("Beacon is within range. Current RSSI: ${device.rssi}");

              // Stop scanning and cancel timers
              scanSubscription?.cancel();
              timeoutTimer?.cancel();
              isScanning = false;

              // Fetch userId from Firebase Auth  (Not sure about this user? thing)
              final user = _authService.getCurrentUser();
              final userId = user?.uid;
              if (userId == null) {
                print("User is not authenticated!");
                return;
              }

              // Fetch the storeID from SQLite using the beaconId
              final storeID = await getStoreIDFromBeacon(beaconId);
              if (storeID != null) {
                // Log the successful beacon scan to Firestore
                await onBeaconDetected(userId, storeID);

                // Complete the completer to indicate success
                completer.complete(true);
              } else {
                print("Beacon ID does not match any store. Skipping check-in.");
              }
            } else {
              print(
                  "Beacon found, but out of range. Current RSSI: ${device.rssi}");
            }
          }
        },
        onError: (error) {
          print("Error scanning for beacons: $error");
          scanSubscription?.cancel();
          timeoutTimer?.cancel();
          isScanning = false;
          completer.complete(false);
        },
        onDone: () {
          isScanning = false;
          timeoutTimer?.cancel();
        },
      );
    }
    return completer.future;
  }

  // Function to handle Firestore integration when a beacon is detected
  Future<void> onBeaconDetected(String userId, String storeID) async {
    try {
      print(
          "Beacon detected. Logging check-in for user $userId at store $storeID.");
      await _firestoreService.addCheckIn(userId: userId, storeID: storeID);
      print("Check-in logged successfully.");
    } catch (e) {
      print("Error logging check-in: $e");
    }
  }

  // Function to find storeID from SQLite table
  Future<String?> getStoreIDFromBeacon(String beaconId) async {
    try {
      // Query SQLite to find the store where mac or iBKS matches the beaconId
      final result = await DatabaseHelper().getStoreByBeacon(beaconId);

      if (result != null && result.isNotEmpty) {
        return result['storeID'].toString(); // Assuming storeID is an integer
      } else {
        print("No store found for beaconId: $beaconId");
        return null;
      }
    } catch (e) {
      print("Error fetching storeID from SQLite: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        leading: IconButton(
          icon: Icon(Icons.person, size: 24), // Profile icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UniversalRewardsScreen()),
            );
          },
        ),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the title
          mainAxisSize: MainAxisSize.min, // Ensure it doesn't take excess space
          children: [
            SvgPicture.asset(
              'assets/images/navpro.svg',
              height: 24,
              width: 24,
            ),
            SizedBox(width: 8),
            Text('Downtown Game'),
          ],
        ),
        centerTitle: true, // Center the title explicitly
        automaticallyImplyLeading: false, // Disable default back button
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 24),
            onPressed: () async {
              await _authService.logOut();
              Navigator.pushReplacementNamed(context, '/');
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
                itemCount: _stores.length,
                itemBuilder: (context, index) {
                  final store = _stores[index];
                  final color = storeItemColors[index % storeItemColors.length];

                  return StoreItem(
                    icon: Icons.map_outlined,
                    name: store['name'],
                    isAvailable: store['isAvailable'] == 'available'
                        ? 'available'
                        : 'unavailable',
                    mac: store['mac'],
                    iBKS: store['iBKS'],
                    onCheckIn: () async {
                      // Get the current time (in milliseconds)
                      final currentTime = DateTime.now().millisecondsSinceEpoch;

                      // Get the store's last successful scan time from the database
                      final lastSuccessfulScanTime =
                          store['lastSuccessfulScanTime'];

                      // Define the cooldown time (2 minutes in milliseconds)
                      final cooldownTime = 2 * 60 * 1000; // 2 minutes

                      // Calculate the remaining cooldown time
                      final remainingTime =
                          (lastSuccessfulScanTime + cooldownTime) - currentTime;
                      print(remainingTime);

                      if (remainingTime > 0) {
                        // If there's remaining cooldown time, show a message with the remaining time
                        final remainingMinutes = remainingTime ~/ 60000;
                        final remainingSeconds =
                            (remainingTime % 60000) ~/ 1000;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "This beacon is cooling down. Next available in $remainingMinutes:$remainingSeconds"),
                          ),
                        );
                        print(
                            "Store is cooling down. Remaining: $remainingMinutes:$remainingSeconds");
                      } else {
                        // If the cooldown is over, allow the scan and update the availability
                        // Update store availability after successful scan
                        String newAvailability = 'available';
                        await DatabaseHelper().updateStoreAvailability(
                          store['storeID'],
                          newAvailability,
                          0,
                        );
                        // Update the store data in the list
                        setState(() {
                          _stores = _stores.map((item) {
                            if (item['storeID'] == store['storeID']) {
                              return {
                                ...item,
                                'isAvailable':
                                    newAvailability, // Change the availability in the store data
                                'lastSuccessfulScanTime':
                                    0, // Store the last successful scan time
                              };
                            }
                            return item;
                          }).toList(); // Rebuild the stores list with updated availability
                        });
                        if (store['isAvailable'] == 'available') {
                          if (Platform.isAndroid) {
                            print("Search using MAC Address");
                            bool isFound = await scanForBeacon(store['mac']);

                            if (isFound) {
                              _addCoins(10); // Add coins if beacon is found

                              // Update store availability after successful scan
                              String newAvailability =
                                  'unavailable'; // Mark as unavailable after successful scan
                              await DatabaseHelper().updateStoreAvailability(
                                store['storeID'],
                                newAvailability,
                                currentTime, // Pass the current timestamp as last scan time
                              );

                              // Update the store data in the list
                              setState(() {
                                _stores = _stores.map((item) {
                                  if (item['storeID'] == store['storeID']) {
                                    return {
                                      ...item,
                                      'isAvailable':
                                          newAvailability, // Change the availability in the store data
                                      'lastSuccessfulScanTime':
                                          currentTime, // Store the last successful scan time
                                    };
                                  }
                                  return item;
                                }).toList(); // Rebuild the stores list with updated availability
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Store is unavailable, cannot scan.")),
                              );
                              print("Scan for beacon returned false");
                            }
                          } else if (Platform.isIOS) {
                            print("Search using ID");
                            bool isFound = await scanForBeacon(store['iBKS']);

                            if (isFound) {
                              _addCoins(10); // Add coins if beacon is found

                              // Update store availability after successful scan
                              String newAvailability =
                                  'unavailable'; // Mark as unavailable after successful scan
                              await DatabaseHelper().updateStoreAvailability(
                                store['storeID'],
                                newAvailability,
                                currentTime, // Pass the current timestamp as last scan time
                              );

                              // Update the store data in the list
                              setState(() {
                                _stores = _stores.map((item) {
                                  if (item['storeID'] == store['storeID']) {
                                    return {
                                      ...item,
                                      'isAvailable':
                                          newAvailability, // Change the availability in the store data
                                      'lastSuccessfulScanTime':
                                          currentTime, // Store the last successful scan time
                                    };
                                  }
                                  return item;
                                }).toList(); // Rebuild the stores list with updated availability
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Store is unavailable, cannot scan.")),
                              );
                              print("Scan for beacon returned false");
                            }
                          }
                        }
                      }
                    },
                    color: color,
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
                    Text('$_coinBalance Coins', style: TextStyle(fontSize: 18)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedBalance = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RewardsScreen()),
                    );
                    if (updatedBalance != null &&
                        updatedBalance != _coinBalance) {
                      setState(() {
                        _coinBalance = updatedBalance;
                      });
                    }
                  },
                  child: Text('Spend Coins'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
