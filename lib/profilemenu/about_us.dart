import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
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
            mainAxisSize: MainAxisSize.min, // Adjusts to content size
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🔹 Title
              Text(
                "About Us",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              SizedBox(height: 15),

              /// 🔹 College & Batch Details
              Text(
                "This application is developed by the 2022-2025 batch of CSE students "
                "from PA Aziz College of Engineering and Technology.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 15),

              /// 🔹 Project Description
              Text(
                "Our project is designed to provide a reliable and user-friendly fuel assistance platform, ensuring help is just a tap away during "
                "emergencies. Whether a vehicle breaks down, runs out of fuel, or requires roadside assistance, "
                "our app connects users with nearby fuel providers and support services instantly",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white54),
              ),
              SizedBox(height: 15),

              /// 🔹 Team Members
              Text(
                "👨‍💻 Team Members:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "• Abijith R A\n"
                "• Prashanth D More\n"
                "• Anupama\n"
                "• Rajaki",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
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
