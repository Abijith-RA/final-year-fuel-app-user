import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportIssuePage extends StatelessWidget {
  const ReportIssuePage({super.key});

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'rapidafil2025@gmail.com',
      queryParameters: {'subject': 'Issue&Report', 'body': 'Dear.Team.\n'},
    );

    if (!await launchUrl(emailUri)) {
      debugPrint("Could not launch email app");
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
          width:
              MediaQuery.of(context).size.width * 0.85, // 85% of screen width
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
                "Report an Issue",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 15),

              /// 🔹 Email Information
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.email, color: Colors.orangeAccent, size: 24),
                  SizedBox(width: 10),
                  Text(
                    "rapidafil2025@gmail.com",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              /// 🔹 Help Message
              const Text(
                "If you're experiencing any issues, please report them by sending an email. "
                "Click the button below to open your email app with a pre-filled report template.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),

              /// 🔹 Send Mail Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _sendEmail,
                child: const Text(
                  "Send Mail",
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
