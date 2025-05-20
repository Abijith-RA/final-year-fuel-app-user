import 'package:flutter/material.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "More Options",
          style: TextStyle(
            color: Colors.orange[400],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.orange[400]),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Next option with zoom effect
            GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _scale = 0.95;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _scale = 1.0;
                });
                // Add your onTap functionality here
              },
              onTapCancel: () {
                setState(() {
                  _scale = 1.0;
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedScale(
                  scale: _scale,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange[400]!.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Next Option",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.orange[400]),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Version information with professional styling
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Version Information",
                    style: TextStyle(
                      color: Colors.orange[400],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Current Version: 1.2.4",
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Latest Update: March 15, 2023",
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "This version includes performance improvements and bug fixes.",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            // Footer with additional info
            Center(
              child: Text(
                "© 2023 Your Company Name. All rights reserved.",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
