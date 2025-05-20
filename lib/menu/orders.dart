import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _canceledOrders = [];
  bool _isLoading = true;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndOrders();
  }

  Future<void> _fetchUserDataAndOrders() async {
    try {
      // Get current user
      final user = _auth.currentUser;
      if (user != null) {
        // Fetch user document from 'users' collection
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userPhone = userDoc.data()?['phone']?.toString();
          });

          if (_userPhone != null) {
            // Fetch canceled orders where phone matches
            final querySnapshot =
                await _firestore
                    .collection('canceledOrders')
                    .where('phone', isEqualTo: _userPhone)
                    .get();

            setState(() {
              _canceledOrders =
                  querySnapshot.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(210, 15, 15, 15),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _canceledOrders.isEmpty
              ? Center(
                child: Text(
                  "No canceled orders found",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _canceledOrders.length,
                itemBuilder: (context, index) {
                  final order = _canceledOrders[index];
                  return Card(
                    color: Colors.grey[800],
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: ${order['orderId'] ?? 'N/A'}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Fuel Type: ${order['fuelType'] ?? 'N/A'}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Quantity: ${order['fuelQuantity']?.toString() ?? 'N/A'}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Total Cost: ₹${order['totalCost']?.toStringAsFixed(2) ?? '0.00'}",
                            style: TextStyle(color: Colors.white),
                          ),
                          if (order['tyreService'] != null)
                            Text(
                              "Tyre Service: ${order['tyreService']}",
                              style: TextStyle(color: Colors.white),
                            ),
                          if (order['situation'] != null)
                            Text(
                              "Issue: ${order['situation']}",
                              style: TextStyle(color: Colors.white),
                            ),
                          SizedBox(height: 8),
                          Text(
                            "Status: Canceled",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Date: ${order['timestamp']?.toString() ?? 'N/A'}",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
