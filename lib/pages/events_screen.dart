import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
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
          // InAppWebView to display the events page
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://downtownsby.com/events/week/"),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                allowsInlineMediaPlayback: true,
                geolocationEnabled: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              // Add additional handlers or methods as needed
            ),
          ),
        ],
      ),
    );
  }
}
