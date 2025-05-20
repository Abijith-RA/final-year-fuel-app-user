import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
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
          padding: EdgeInsets.all(20),
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
              Text(
                "Help & Support",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              SizedBox(height: 15),

              /// 🔹 Change Name
              Text(
                "Want to change your name?",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                "Go to Profile and update your name there.",
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),

              /// 🔹 Select District
              Text(
                "Need to update your district?",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                "Select your district from the Profile section.",
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),

              /// 🔹 Change Password
              Text(
                "Want to change your password?",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                "Go to Password Change, enter your current password and new password.",
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),

              /// 🔹 Report an Issue
              Text(
                "Facing an issue?",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                "Send an email to our support team for assistance.",
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              /// 🔹 Close Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Close",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
