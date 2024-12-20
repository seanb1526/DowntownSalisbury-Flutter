import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothPermissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center the content
        children: [
          // Small rectangle at the top to account for the notch
          Container(
            height: MediaQuery.of(context).padding.top, // Height for the notch
            color: Color(0xFF019FDC), // Color for the rectangle
          ),
          SizedBox(height: 16), // Space after the rectangle

          // Title Text
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0), // Add padding
            child: Text(
              "Enable Bluetooth",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
              height: 16), // Space between the title and the Bluetooth icon

          // Bluetooth Icon
          Icon(
            Icons.bluetooth, // Bluetooth icon
            size: 60,
            color: Color(0xFF019FDC), // Same color as the rectangle
          ),
          SizedBox(
              height: 32), // Space between the icon and the description text

          // Description Text
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0), // Add padding
            child: Text(
              "We need Bluetooth to establish connections to Echo's. Please enable Bluetooth on your phone. Then press the button below to allow permissions.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Spacer(), // This will push the button toward the bottom

          // Enable Bluetooth Button
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0), // Add bottom padding
            child: ElevatedButton(
              onPressed: () async {
                final FlutterReactiveBle flutterReactiveBle =
                    FlutterReactiveBle();

                try {
                  final bleStatus =
                      await flutterReactiveBle.statusStream.firstWhere(
                    (status) => status == BleStatus.ready,
                    orElse: () => BleStatus.unknown,
                  );

                  if (bleStatus == BleStatus.ready) {
                    print("Bluetooth is ready");
                  } else if (bleStatus == BleStatus.unknown) {
                    print("Unable to determine Bluetooth status");
                  } else {
                    print("Bluetooth is not ready: $bleStatus");
                  }
                } catch (e) {
                  print("Error checking Bluetooth status: $e");
                }
              },
              child: Text("Enable Bluetooth"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF019FDC), // Button color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
