import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NearRefuelStationPage extends StatelessWidget {
  const NearRefuelStationPage({super.key});

  Future<void> _openGoogleMaps() async {
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=fuel+stations+near+me",
    );

    if (!await launchUrl(googleMapsUrl)) {
      debugPrint("Could not open Google Maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
        0.8,
      ), // Semi-transparent overlay
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85, // 85% width
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orangeAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🔹 Title
              const Text(
                "Near Refuel Pump",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 15),

              /// 🔹 Description
              const Text(
                "Find the nearest fuel stations using Google Maps. Click the button below to search for fuel stations near you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),

              /// 🔹 Find Nearby Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: _openGoogleMaps,
                icon: const Icon(Icons.map, color: Colors.black),
                label: const Text(
                  "Find Nearby Fuel Stations",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔹 Close Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Close",
                  style: TextStyle(fontSize: 16, color: Colors.orangeAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
