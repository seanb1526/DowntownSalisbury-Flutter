import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Ensures content is within the safe area
        child: Column(
          children: [
            // InAppWebView to display the events page
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://www.3rdfridaysby.com/line-up"),
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
      ),
    );
  }
}
