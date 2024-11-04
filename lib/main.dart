import 'package:flutter/material.dart';
import 'pages/home_screen.dart';
import 'pages/map_screen.dart';
import 'pages/events_screen.dart';
import 'pages/more_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Request permission for notifications (only needed for iOS)
  FirebaseMessaging.instance.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tab Navigation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    MapScreen(),
    EventsScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Handle push notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received message while app is open: ${message.notification?.title}');
      // You could display an in-app notification or show a dialog here
    });

    // Handle push notifications when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tapped on notification: ${message.notification?.title}');
      // Navigate to a specific screen or perform other actions based on the notification data
    });

    // Optional: Handle any initial message if the app was launched from a notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('App launched from notification: ${message.notification?.title}');
        // Navigate to a specific screen if needed
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: '3rd Friday',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
