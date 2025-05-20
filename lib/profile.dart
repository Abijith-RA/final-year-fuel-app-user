import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myprofile.dart';
import 'registration_page.dart';

// Import profile menu pages
import 'profilemenu/help_support.dart';
import 'profilemenu/about_us.dart';
import 'profilemenu/change_password.dart';
import 'profilemenu/report_issue.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = "Loading..."; // Placeholder while fetching data

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  /// ✅ Fetch User Name from Firestore using user UID
  Future<void> _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _userName = userDoc['name'] ?? "User"; // ✅ Fetching 'name' field
        });
      } else {
        setState(() {
          _userName = "User"; // Fallback if document does not exist
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
      setState(() {
        _userName = "User"; // Ensure UI updates even on error
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orangeAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 30),

          /// 🔹 Circular Profile Button (Shows User Name)
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfilePage()),
              );
              _fetchUserName(); // Reload name after returning
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: Colors.black, size: 30),
                    SizedBox(height: 5),
                    Text(
                      _userName, // ✅ Displays fetched user name
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 50),

          /// 🔹 Profile Menu (Each Button Navigates to a Different Page)
          profileMenuItem(Icons.help, "Help & Support", HelpSupportPage()),
          profileMenuItem(Icons.info, "About Us", AboutUsPage()),
          profileMenuItem(
            Icons.person_outline,
            "Change Password",
            ChangePasswordPage(),
          ),
          profileMenuItem(
            Icons.help_outline,
            "Report Issue",
            ReportIssuePage(),
          ),

          SizedBox(height: 20),

          /// 🔹 Logout Button
          GestureDetector(
            onTap: () => _logout(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(14),
              margin: EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orangeAccent, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 🔹 Profile Menu Item
  Widget profileMenuItem(IconData icon, String title, Widget page) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orangeAccent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orangeAccent, size: 24),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}
