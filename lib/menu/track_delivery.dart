import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rapidfil/placeorder/order_tracking.dart';

class TrackDeliveryPage extends StatefulWidget {
  @override
  _TrackDeliveryPageState createState() => _TrackDeliveryPageState();
}

class _TrackDeliveryPageState extends State<TrackDeliveryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  String? _latestOrderId;
  Map<String, dynamic>? _orderData;
  String _statusMessage = '';
  bool _showTrackButton = false;

  @override
  void initState() {
    super.initState();
    _checkRecentOrders();
  }

  Future<void> _checkRecentOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'User not authenticated';
        });
        return;
      }

      // Get orders from the last 15 minutes
      final fifteenMinutesAgo = DateTime.now().subtract(Duration(minutes: 15));

      // First check process collection (active orders)
      final processQuery =
          await _firestore
              .collection('process')
              .where('userId', isEqualTo: user.uid)
              .where('timestamp', isGreaterThanOrEqualTo: fifteenMinutesAgo)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (processQuery.docs.isNotEmpty) {
        // Order is in process - show tracking
        final doc = processQuery.docs.first;
        _navigateToTracking(doc.id, doc.data());
        return;
      }

      // If no process order, check confirmorder
      final confirmOrderQuery =
          await _firestore
              .collection('confirmorder')
              .where('userId', isEqualTo: user.uid)
              .where('timestamp', isGreaterThanOrEqualTo: fifteenMinutesAgo)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (confirmOrderQuery.docs.isNotEmpty) {
        final doc = confirmOrderQuery.docs.first;
        final data = doc.data();

        setState(() {
          _latestOrderId = doc.id;
          _orderData = data;
          _statusMessage = 'Waiting for delivery boy';
          _showTrackButton = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = 'No recent orders found';
          _showTrackButton = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking recent orders: $e');
      setState(() {
        _statusMessage = 'Error loading orders';
        _showTrackButton = false;
        _isLoading = false;
      });
    }
  }

  void _navigateToTracking(String orderId, Map<String, dynamic> orderData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderTrackingPage(
              orderId: orderId,
              pumpName: orderData['pumpName']?.toString() ?? 'Unknown Pump',
              pumpAddress:
                  orderData['pumpAddress']?.toString() ?? 'Unknown Address',
              deliveryAddress:
                  orderData['deliveryAddress']?.toString() ?? 'Unknown Address',
              distance: (orderData['distance'] as num?)?.toDouble() ?? 0.0,
              fromUpdatePage: true,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Delivery"),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(210, 15, 15, 15),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange))
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    if (_showTrackButton && _latestOrderId != null)
                      ElevatedButton(
                        onPressed:
                            () => _navigateToTracking(
                              _latestOrderId!,
                              _orderData!,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        child: Text(
                          "TRACK ORDER",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _checkRecentOrders,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        "REFRESH STATUS",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
