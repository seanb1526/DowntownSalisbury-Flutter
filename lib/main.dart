import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure to have your Firebase options

// Import your pages
import 'pages/home_screen.dart';
import 'pages/login_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/map_screen.dart';
import 'pages/events_screen.dart';
import 'pages/beacon_home_screen.dart';
import 'pages/rewards_screen.dart';
import 'firebase_auth.dart'; // Import your Firebase Auth Service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex; // Added to accept the starting index

  const MainScreen({super.key, this.initialIndex = 0}); // Default to 0

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int
      _selectedIndex; // Use 'late' to indicate it will be initialized later

  final List<Widget> _pages = [
    HomeScreen(),
    MapScreen(),
    EventsScreen(),
    BeaconHomeScreen(), // This will be accessed after login
  ];

  // Check if the user is logged in using FirebaseAuth
  Future<bool> _isUserLoggedIn() async {
    return await FirebaseAuthService().isLoggedIn();
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set the selected index
  }

  void _onItemTapped(int index) async {
    if (index == 3) {
      // Beacon Home
      bool loggedIn = await _isUserLoggedIn();
      if (!loggedIn) {
        // If not logged in, navigate to LoginScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return;
      }
    }

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_activity), label: 'Beacons'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
