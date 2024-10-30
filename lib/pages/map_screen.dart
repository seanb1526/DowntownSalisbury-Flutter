import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  InAppWebViewController? _webViewController;
  final String initialUrl =
      "https://experience.arcgis.com/experience/17a7e758549e433baa6b964b2004fb2e/?draft=true";
  String? currentUrl; // Variable to track the current URL

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      print("Location permission granted");
    } else if (status.isDenied) {
      print("Location permission denied");
    } else if (status.isPermanentlyDenied) {
      print(
          "Location permission permanently denied. Please enable it in settings.");
      openAppSettings();
    }
  }

  Future<void> launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      print("Could not launch $url");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to make calls from this device."),
        ),
      );
    }
  }

  Future<void> _goBack() async {
    if (_webViewController != null) {
      final canGoBack = await _webViewController!
          .canGoBack(); // Check if we can go back in web view
      if (canGoBack) {
        _webViewController!.goBack(); // Go back in web view history
      } else {
        Navigator.pop(context); // Navigate back to the previous screen
      }
    } else {
      Navigator.pop(context); // Navigate back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(initialUrl),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            allowsInlineMediaPlayback: true,
            geolocationEnabled: true,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              currentUrl = url?.toString(); // Update the current URL
            });
          },
          onLoadStop: (controller, url) async {
            setState(() {
              currentUrl =
                  url?.toString(); // Update the current URL when load stops
            });
          },
          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            return GeolocationPermissionShowPromptResponse(
              origin: origin,
              allow: true,
              retain: true,
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url?.toString();

            if (url != null && url.startsWith('tel:')) {
              // Intercept and handle the tel: link
              await launchURL(url);
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
        ),
      ),
      floatingActionButton: (currentUrl !=
              initialUrl) // Check if current URL is different from initial
          ? FloatingActionButton(
              onPressed: _goBack, // Call the back navigation method
              child: const Icon(Icons.arrow_back),
              tooltip: 'Back', // Tooltip for accessibility
            )
          : null, // Do not show button if at the initial URL
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Position at the bottom right
    );
  }
}
