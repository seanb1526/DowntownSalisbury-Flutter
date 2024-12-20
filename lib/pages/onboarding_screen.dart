import 'package:downtown_salisbury/main.dart';
import 'package:flutter/material.dart';
import './onboarding/bluetooth_permissions_page.dart';
import './onboarding/how_to_play_page.dart';
import './onboarding/terms_page.dart';
import './onboarding/welcome_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController =
      PageController(); // Controls the PageView
  int _currentPage = 0; // Tracks the current page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // PageView for swiping between pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                WelcomePage(),
                HowToPlayPage(),
                BluetoothPermissionsPage(),
                TermsPage(),
              ],
            ),
          ),

          // SmoothPageIndicator (dots)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip button
                if (_currentPage < 3)
                  TextButton(
                    onPressed: () {
                      _pageController.jumpToPage(3); // Skip to Terms
                    },
                    child: Text("Skip"),
                  ),

                // Page indicators
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 4,
                  effect: WormEffect(), // Customize this!
                ),

                // Next or Finish button
                TextButton(
                  onPressed: () {
                    if (_currentPage < 3) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(initialIndex: 3),
                        ),
                      );
                    }
                  },
                  child: Text(_currentPage < 3 ? "Next" : "Finish"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
