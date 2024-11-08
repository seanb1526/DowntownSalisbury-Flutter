import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _requestNotificationPermission();
  }

  Future<void> _requestLocationPermission() async {
    // Request always permission first as a test
    await Permission.locationAlways.request();
    // Now request "when in use" permission
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      print("Location permission granted.");
    } else {
      print("Location permission denied.");
    }
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
      body: Column(
        children: [
          // Header Image with Padding and Proper Sizing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 200, // Adjust the height as needed
              child: Image.asset(
                'assets/images/DownTownSalisbury.png',
                fit: BoxFit.contain, // Makes sure the image fits within bounds
              ),
            ),
          ),
          // Spacer to provide some gap between the image and the grid
          const SizedBox(height: 20),
          // Grid of circular buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 items per row
                  childAspectRatio: 1, // Make the buttons square
                  crossAxisSpacing: 20, // Horizontal spacing between buttons
                  mainAxisSpacing: 20, // Vertical spacing between buttons
                ),
                itemCount: buttons.length,
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
          ),
        ],
      ),
    );
  }
}
