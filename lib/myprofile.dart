import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userEmail = "Loading...";
  String userId = "";
  String selectedCountry = "India";
  String selectedState = "";
  String selectedDistrict = "";
  String selectedCity = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController =
      TextEditingController(); // New district controller

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? "No Email";
        _emailController.text = _userEmail;
      });

      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            userId = user.uid;
            _nameController.text = userData['name'] ?? "Your Name";
            _phoneController.text = userData['phone'] ?? "";
            selectedCountry = userData['country'] ?? "India";
            selectedState = userData['state'] ?? "";
            selectedDistrict = userData['district'] ?? "";
            selectedCity = userData['city'] ?? "";

            _districtController.text = selectedDistrict; // Set district
            _cityController.text = selectedCity;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _updateUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null || userId.isEmpty) {
      print("Error: No authenticated user found");
      return;
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'name': _nameController.text.trim(),
        'country': selectedCountry,
        'state': selectedState,
        'district': _districtController.text.trim(), // Save district
        'city': _cityController.text.trim(),
      });

      print("User profile updated successfully");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
    } catch (e) {
      print("Error saving user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "My Profile",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orangeAccent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.orangeAccent),
            onPressed: _updateUserProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            profileDetail("Name", _nameController, isEditable: true),
            profileDetail("Email", _emailController, isEditable: false),
            profileDetail("Phone", _phoneController, isEditable: false),
            dropdownField("Country", ["India"], selectedCountry, (value) {}),
            dropdownField(
              "State",
              [
                "Andhra Pradesh",
                "Arunachal Pradesh",
                "Assam",
                "Bihar",
                "Chhattisgarh",
                "Goa",
                "Gujarat",
                "Haryana",
                "Himachal Pradesh",
                "Jharkhand",
                "Karnataka",
                "Kerala",
                "Madhya Pradesh",
                "Maharashtra",
                "Manipur",
                "Meghalaya",
                "Mizoram",
                "Nagaland",
                "Odisha",
                "Punjab",
                "Rajasthan",
                "Sikkim",
                "Tamil Nadu",
                "Telangana",
                "Tripura",
                "Uttar Pradesh",
                "Uttarakhand",
                "West Bengal",
              ],
              selectedState.isNotEmpty ? selectedState : null,
              (value) {
                setState(() {
                  selectedState = value;
                  selectedDistrict = "";
                  _districtController.text = "";
                });
              },
            ),

            profileDetail(
              "District",
              _districtController,
              isEditable: true,
            ), // Added district input
            profileDetail("City", _cityController, isEditable: true),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget profileDetail(
    String label,
    TextEditingController controller, {
    bool isEditable = true,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent, width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 16,
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child:
                isEditable
                    ? TextField(
                      controller: controller,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.black,
                      ),
                    )
                    : Text(
                      controller.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget dropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent, width: 1.5),
      ),
      child: DropdownButton<String>(
        dropdownColor: Colors.black,
        isExpanded: true,
        value: selectedValue,
        hint: Text(label, style: TextStyle(color: Colors.white54)),
        icon: Icon(Icons.arrow_drop_down, color: Colors.orangeAccent),
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
        onChanged: (value) => onChanged(value!),
      ),
    );
  }
}
