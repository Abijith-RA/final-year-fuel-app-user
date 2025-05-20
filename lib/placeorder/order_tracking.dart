import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  final String pumpName;
  final String pumpAddress;
  final String deliveryAddress;
  final double distance;
  final int? initialStep;
  final bool fromUpdatePage;

  const OrderTrackingPage({
    Key? key,
    required this.orderId,
    required this.pumpName,
    required this.pumpAddress,
    required this.deliveryAddress,
    required this.distance,
    this.initialStep,
    this.fromUpdatePage = false,
  }) : super(key: key);

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late int currentStep;
  bool isDeliveryCompleted = false;
  bool isLoading = true;
  late StreamSubscription<DocumentSnapshot> _processSubscription;
  String verificationCode = '';
  bool showVerificationButton = false;

  @override
  void initState() {
    super.initState();
    currentStep = widget.initialStep ?? 1;
    _initializeOrder();
  }

  @override
  void dispose() {
    _processSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeOrder() async {
    try {
      // Generate verification code first
      verificationCode = _generateVerificationCode();

      // Check both collections
      DocumentSnapshot orderDoc =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.orderId)
              .get();

      DocumentSnapshot processDoc =
          await FirebaseFirestore.instance
              .collection('process')
              .doc(widget.orderId)
              .get();

      if (orderDoc.exists) {
        final orderData = orderDoc.data() as Map<String, dynamic>?;
        setState(() {
          verificationCode = orderData?['verificationCode'] ?? verificationCode;
        });

        // Update the order with verification code if it wasn't there before
        if (orderData?['verificationCode'] == null) {
          await _updateOrderWithVerificationCode();
        }
      } else {
        // Save the new order with verification code
        await _saveOrderToDatabase();
      }

      if (processDoc.exists) {
        final processData = processDoc.data() as Map<String, dynamic>?;
        _updateStepBasedOnStatus(processData?['status']);
      }

      setState(() => isLoading = false);

      // Setup process collection listener
      _processSubscription = FirebaseFirestore.instance
          .collection('process')
          .doc(widget.orderId)
          .snapshots()
          .listen((doc) {
            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                _updateStepBasedOnStatus(data['status']);
              }
            }
          });
    } catch (e) {
      print('Error initializing order: $e');
      setState(() => isLoading = false);
    }
  }

  void _updateStepBasedOnStatus(String? status) {
    if (status == null) return;

    setState(() {
      if (status == 'delivered') {
        currentStep = 5;
        isDeliveryCompleted = true;
        showVerificationButton = true;
      } else if (status == 'reachlocation') {
        currentStep = 4;
        isDeliveryCompleted = false;
        showVerificationButton = false;
      } else if (status == 'dispatched') {
        currentStep = 3;
        isDeliveryCompleted = false;
        showVerificationButton = false;
      } else if (status == 'process') {
        currentStep = 2;
        isDeliveryCompleted = false;
        showVerificationButton = false;
      } else if (status == 'confirmed') {
        currentStep = 1;
        isDeliveryCompleted = false;
        showVerificationButton = false;
      } else if (status == 'location_added') {
        currentStep = 0;
        isDeliveryCompleted = false;
        showVerificationButton = false;
      }
    });
  }

  String _generateVerificationCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> _updateOrderWithVerificationCode() async {
    try {
      final updateData = {
        'verificationCode': verificationCode,
        'otp': verificationCode,
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update(updateData);

      // Also update confirmorder collection
      await _copyToConfirmOrder(updateData);
    } catch (e) {
      print('Error updating order with verification code: $e');
    }
  }

  Future<void> _saveOrderToDatabase() async {
    try {
      final orderData = {
        'orderId': widget.orderId,
        'pumpName': widget.pumpName,
        'pumpAddress': widget.pumpAddress,
        'deliveryAddress': widget.deliveryAddress,
        'distance': widget.distance,
        'status': 'confirmed',
        'verificationCode': verificationCode,
        'otp': verificationCode,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .set(orderData);

      // Also save to confirmorder collection
      await _copyToConfirmOrder(orderData);
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  Future<void> _copyToConfirmOrder(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('confirmorder')
          .doc(widget.orderId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error copying to confirmorder collection: $e');
    }
  }

  Future<void> _markDeliveryAsComplete() async {
    try {
      final updateData = {
        'status': 'delivered',
        'deliveredAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('process')
          .doc(widget.orderId)
          .update(updateData);

      // Also update confirmorder collection
      await FirebaseFirestore.instance
          .collection('confirmorder')
          .doc(widget.orderId)
          .update(updateData);

      _handleCompleteOrder();
    } catch (e) {
      print('Error marking delivery as complete: $e');
    }
  }

  void _handleCompleteOrder() {
    Navigator.pushNamed(context, '/feedback', arguments: widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            "Order Tracking",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange,
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
                : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ORDER STATUS",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Column(
                            children: [
                              _buildProgressStep(
                                "Location Added",
                                currentStep >= 0,
                                0,
                              ),
                              _buildProgressLine(),
                              _buildProgressStep(
                                "Confirmed",
                                currentStep >= 1,
                                1,
                              ),
                              _buildProgressLine(),
                              _buildProgressStep(
                                "Processing",
                                currentStep >= 2,
                                2,
                              ),
                              _buildProgressLine(),
                              _buildProgressStep(
                                "Dispatched",
                                currentStep >= 3,
                                3,
                              ),
                              _buildProgressLine(),
                              _buildProgressStep(
                                "Reached Location",
                                currentStep >= 4,
                                4,
                              ),
                              _buildProgressLine(),
                              _buildProgressStep(
                                "Delivered",
                                currentStep >= 5,
                                5,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "DELIVERY INFORMATION",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow("From:", widget.pumpName),
                              const SizedBox(height: 5),
                              _buildInfoRow(
                                "Pump Address:",
                                widget.pumpAddress,
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow("To:", widget.deliveryAddress),
                              const SizedBox(height: 10),
                              Text(
                                "Distance: ${widget.distance.toStringAsFixed(1)} km",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "OTP: $verificationCode",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (currentStep >= 5 && !isDeliveryCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _markDeliveryAsComplete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                "DELIVERY RECEIVED",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        if (isDeliveryCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleCompleteOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                "PROVIDE FEEDBACK",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildProgressStep(String text, bool isCompleted, int stepNumber) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : Colors.grey[700],
            border: Border.all(
              color: isCompleted ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              stepNumber > 0 ? stepNumber.toString() : "",
              style: TextStyle(
                color: isCompleted ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: isCompleted ? Colors.green : Colors.white,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine() {
    return Container(
      margin: const EdgeInsets.only(left: 14),
      height: 20,
      width: 2,
      color: Colors.grey,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
