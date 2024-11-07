import 'package:downtown_salisbury/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import '../helpers/sqflite_helper.dart'; // Import your DatabaseHelper

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables to store data
  List<Map<String, dynamic>> stores = [];
  int? userCurrency;
  String storesStatus =
      ''; // For displaying table status (exists, empty, nonexistent)

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    initializeStores();
    _loadDatabaseData();
  }

  // Method to request notification permissions
  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Method to open a URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Load and print both tables (user_currency and stores)
  void _loadDatabaseData() async {
    // Get the currency balance for a user (example user_id = 'user123')
    final currencyResult =
        await DatabaseHelper().getCurrency('9R2qg6ySEHcXJwpMZAmvVxncJVJ2');
    setState(() {
      userCurrency = currencyResult;
    });

    // Get all stores from the stores table
    try {
      final storesResult = await DatabaseHelper().getAllStores();
      setState(() {
        stores = storesResult;
      });

      if (stores.isEmpty) {
        setState(() {
          storesStatus = 'Stores table is empty';
        });
      }
    } catch (e) {
      setState(() {
        storesStatus = 'Stores table does not exist';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of button details (icon, label, and URL)
    final List<Map<String, dynamic>> buttons = [
      {
        'icon': Icons.local_parking,
        'label': 'Parking',
        'url': 'https://downtownsby.com/get-downtown/'
      },
      {
        'icon': Icons.article,
        'label': 'News',
        'url': 'https://salisbury.md/news'
      },
      {
        'icon': Icons.share,
        'label': 'Social Media',
        'url': 'https://www.instagram.com/downtownsalisburymd/?hl=en'
      },
      {
        'icon': Icons.wb_sunny,
        'label': 'Weather',
        'url':
            'https://weather.com/weather/today/l/f1c10bddbc2e3be4339e4d2d35db9b980084cacb6418b0aa09e1c17c00a29194' // Salisbury, MD weather link
      },
      {
        'icon': Icons.card_giftcard,
        'label': 'Gift Cards',
        'url': 'https://app.yiftee.com/gift-card/salisbury'
      },
      {
        'icon': Icons.contact_mail,
        'label': 'Contact Us',
        'url': 'https://downtownsby.com/contact-us/'
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image with Padding and Proper Sizing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 200, // Adjust the height as needed
                child: Image.asset(
                  'assets/images/DownTownSalisbury.png',
                  fit:
                      BoxFit.contain, // Makes sure the image fits within bounds
                ),
              ),
            ),
            // Spacer to provide some gap between the image and the grid
            const SizedBox(height: 20),
            // Grid of circular buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 items per row
                  childAspectRatio: 1, // Make the buttons square
                  crossAxisSpacing: 20, // Horizontal spacing between buttons
                  mainAxisSpacing: 20, // Vertical spacing between buttons
                ),
                itemCount: buttons.length,
                shrinkWrap: true, // Make grid take only necessary space
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      // Circular button with icon
                      InkWell(
                        onTap: () {
                          // Open the URL when the button is tapped
                          _launchURL(buttons[index]['url']);
                        },
                        child: Container(
                          width: 80, // Circle diameter
                          height: 80, // Circle diameter
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent, // Button background color
                          ),
                          child: Icon(
                            buttons[index]['icon'], // Icon inside the button
                            size: 40,
                            color: Colors.white, // Icon color
                          ),
                        ),
                      ),
                      // Label below the button
                      Text(
                        buttons[index]['label'], // Button label
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Display User Currency
            if (userCurrency != null)
              Text(
                'User Currency: $userCurrency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            // Display Stores Table Status
            if (storesStatus.isNotEmpty)
              Text(
                storesStatus,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            // Display Stores Table if the table exists and has data
            if (stores.isNotEmpty) ...[
              const SizedBox(height: 20),
              ...stores.map((store) {
                return ListTile(
                  title: Text(store['store_name']),
                  subtitle: Text('Beacon ID: ${store['beacon_id']}'),
                  trailing: Text(store['is_available'] == 1
                      ? 'Available'
                      : 'Not Available'),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
