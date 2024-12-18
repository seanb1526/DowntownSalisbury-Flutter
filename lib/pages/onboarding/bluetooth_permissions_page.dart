import 'package:flutter/material.dart';

class BluetoothPermissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Enable Bluetooth",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            "We need Bluetooth access to scan for beacons.",
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: () {
              // Request Bluetooth permissions here
            },
            child: Text("Enable Bluetooth"),
          ),
        ],
      ),
    );
  }
}
