import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (!_isValidPassword(newPassword)) {
      _showMessage(
        "New password must be at least 8 characters, include a number and an uppercase letter.",
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (newPassword != confirmNewPassword) {
      _showMessage("New passwords do not match.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      // **Update Password in Firestore**
      await FirebaseFirestore.instance
          .collection('users') // Adjust collection name if needed
          .doc(user.uid)
          .update({
            'password': newPassword,
          }); // Ensure secure handling (hashing recommended)

      _showMessage("Password updated successfully.");

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showMessage("Error: \${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Change Password",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orangeAccent),
          onPressed: () {
            Navigator.pop(context); // Now back button works
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPasswordField(
              "Current Password",
              _currentPasswordController,
              _currentPasswordVisible,
              () {
                setState(() {
                  _currentPasswordVisible = !_currentPasswordVisible;
                });
              },
            ),
            SizedBox(height: 16),
            _buildPasswordField(
              "New Password",
              _newPasswordController,
              _newPasswordVisible,
              () {
                setState(() {
                  _newPasswordVisible = !_newPasswordVisible;
                });
              },
            ),
            SizedBox(height: 16),
            _buildPasswordField(
              "Confirm New Password",
              _confirmNewPasswordController,
              _confirmNewPasswordVisible,
              () {
                setState(() {
                  _confirmNewPasswordVisible = !_confirmNewPasswordVisible;
                });
              },
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: _isLoading ? null : _changePassword,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.black)
                          : Text(
                            "Update Password",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isPasswordVisible,
    VoidCallback toggleVisibility,
  ) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.orangeAccent),
        filled: true,
        fillColor: Colors.black87,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orangeAccent),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.orangeAccent,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
