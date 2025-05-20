import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  late Stream<Map<String, String>> _userDataStream;

  @override
  void initState() {
    super.initState();
    _userDataStream = _loadUserData();
  }

  Stream<Map<String, String>> _loadUserData() async* {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";

    if (userId.isEmpty) {
      yield {'name': 'Guest', 'email': 'Not logged in'};
      return;
    }

    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return {'name': 'User', 'email': user?.email ?? 'No email'};
          }

          return {
            'name': doc['name']?.toString() ?? 'User',
            'email': doc['email']?.toString() ?? user?.email ?? 'No email',
          };
        })
        .handleError((error) {
          return {'name': 'Error', 'email': 'Could not load profile'};
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Header with menu icon and text
            SafeArea(
              bottom: false,
              minimum: EdgeInsets.zero,
              child: _buildHeaderContent(),
            ),
            // Menu Items
            Expanded(
              child: Container(
                color: Colors.black,
                child: _buildMenuItems(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      children: [
        _buildMenuItem(
          icon: Icons.home,
          title: "Home",
          onTap: () => Navigator.pop(context),
        ),
        _buildMenuItem(
          icon: Icons.local_shipping,
          title: "Canceled Orders",
          onTap: () => Navigator.pushNamed(context, '/orders'),
        ),
        _buildMenuItem(
          icon: Icons.map,
          title: "Fuel Stations",
          onTap: () => Navigator.pushNamed(context, '/fuel_stations'),
        ),
        _buildMenuItem(
          icon: Icons.directions_car,
          title: "Track Delivery",
          onTap: () => Navigator.pushNamed(context, '/track_delivery'),
        ),
        _buildMenuItem(
          icon: Icons.payment,
          title: "Payments",
          onTap: () => Navigator.pushNamed(context, '/payments'),
        ),
        _buildMenuItem(
          icon: Icons.local_gas_station,
          title: "Near Refuel Pump",
          onTap: () => Navigator.pushNamed(context, '/near_refuel_pump'),
        ),
      ],
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu, size: 30, color: Colors.black),
          const SizedBox(width: 12),
          const Text(
            'Menu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.orange.withOpacity(0.3),
        highlightColor: Colors.orange.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
