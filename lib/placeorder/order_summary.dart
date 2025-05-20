import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_tracking.dart';

class OrderSummaryPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> fuelSelectionData;
  final Map<String, dynamic> selectedPump;
  final LatLng userLocation;
  final double? distanceInKm;
  final String address;

  const OrderSummaryPage({
    Key? key,
    required this.orderId,
    required this.fuelSelectionData,
    required this.selectedPump,
    required this.userLocation,
    required this.distanceInKm,
    required this.address,
  }) : super(key: key);

  Future<void> _confirmOrder(BuildContext context) async {
    try {
      // Validate user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      // Set default values if any field is missing
      final price = (fuelSelectionData['price'] as num?)?.toDouble() ?? 0.0;
      final quantity =
          (fuelSelectionData['quantity'] as num?)?.toDouble() ?? 0.0;
      final distance = distanceInKm ?? 0.0;
      final fuelType = fuelSelectionData['fuelType']?.toString() ?? 'Petrol';
      final fuelCost =
          (fuelSelectionData['totalCost'] as num?)?.toDouble() ??
          price * quantity;

      // Calculate costs with defaults
      final deliveryCharge = distance * 20;
      final totalCost = fuelCost + deliveryCharge;

      // Prepare order data with safe defaults
      final orderData = {
        'userId': user.uid,
        'orderId': orderId,
        'fuelType': fuelType,
        'fuelQuantity': quantity,
        'quantity': quantity,
        'price': price,
        'fuelCost': fuelCost,
        'deliveryCharge': deliveryCharge,
        'totalCost': totalCost,
        'pumpId': selectedPump['id']?.toString() ?? '',
        'pumpName': selectedPump['name']?.toString() ?? 'Unknown Pump',
        'pumpAddress': selectedPump['address']?.toString() ?? 'Unknown Address',
        'pumpLocation': GeoPoint(
          (selectedPump['location'] as LatLng?)?.latitude ?? 0.0,
          (selectedPump['location'] as LatLng?)?.longitude ?? 0.0,
        ),
        'deliveryAddress': address,
        'deliveryLocation': GeoPoint(
          userLocation.latitude,
          userLocation.longitude,
        ),
        'distance': distance,
        'phone': user.phoneNumber ?? '+91 8590071749',
        'status': 'pending',
        'situation': 'Order placed',
        'name': selectedPump['operatorName']?.toString() ?? 'Achu',
        'locationUpdated': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Prepare confirm order data with expiration time (10 minutes from now)
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      final confirmOrderData = {
        'address': address,
        'deliveryCharge': deliveryCharge,
        'fuelQuantity': quantity,
        'fuelType': fuelType,
        'location': GeoPoint(userLocation.latitude, userLocation.longitude),
        'locationUpdatedAt': FieldValue.serverTimestamp(),
        'name': selectedPump['operatorName']?.toString() ?? 'Achu',
        'orderId': orderId,
        'phone': user.phoneNumber ?? '+91 8590071749',
        'situation': 'Order placed',
        'status': 'location_added',
        'timestamp': FieldValue.serverTimestamp(),
        'totalCost': totalCost,
        'userId': user.uid,
        'pumpAddress': selectedPump['address']?.toString() ?? 'Unknown Address',
        'pumpLocation': GeoPoint(
          (selectedPump['location'] as LatLng?)?.latitude ?? 0.0,
          (selectedPump['location'] as LatLng?)?.longitude ?? 0.0,
        ),
        'expiresAt': Timestamp.fromDate(expiresAt), // Add expiration timestamp
      };

      // Save to Firestore using batch write
      final batch = FirebaseFirestore.instance.batch();

      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);
      batch.set(orderRef, orderData, SetOptions(merge: true));

      final confirmOrderRef = FirebaseFirestore.instance
          .collection('confirmorder')
          .doc(orderId);
      batch.set(confirmOrderRef, confirmOrderData);

      await batch.commit();

      // Navigate to tracking page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => OrderTrackingPage(
                orderId: orderId,
                pumpName: selectedPump['name']?.toString() ?? 'Unknown Pump',
                pumpAddress:
                    selectedPump['address']?.toString() ?? 'Unknown Address',
                deliveryAddress: address,
                distance: distance,
              ),
        ),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order confirmed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming order: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe calculations with defaults
    final price = (fuelSelectionData['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = (fuelSelectionData['quantity'] as num?)?.toDouble() ?? 0.0;
    final fuelCost =
        (fuelSelectionData['totalCost'] as num?)?.toDouble() ??
        price * quantity;
    final distance = distanceInKm ?? 0.0;

    final deliveryCharge = distance * 20;
    final totalCost = fuelCost + deliveryCharge;
    final isWithinDistance = distance <= 15;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Order Summary",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID
              Text(
                "ORDER ID: $orderId",
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Fuel Details Card
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
                      "FUEL DETAILS",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      "Fuel Type:",
                      fuelSelectionData['fuelType']?.toString() ?? 'Petrol',
                    ),
                    _buildDetailRow(
                      "Quantity:",
                      "${quantity.toStringAsFixed(1)} L",
                    ),
                    _buildDetailRow(
                      "Price per liter:",
                      "₹${price.toStringAsFixed(2)}",
                    ),
                    _buildDetailRow(
                      "Fuel Cost:",
                      "₹${fuelCost.toStringAsFixed(2)}",
                    ),
                    _buildDetailRow(
                      "Delivery Charge (₹20/km):",
                      "₹${deliveryCharge.toStringAsFixed(2)}",
                    ),
                    const Divider(color: Colors.grey),
                    _buildDetailRow(
                      "TOTAL (including delivery):",
                      "₹${totalCost.toStringAsFixed(2)}",
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pump Details Card
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
                      "SELECTED PUMP",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedPump['name']?.toString() ?? 'Unknown Pump',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      selectedPump['address']?.toString() ?? 'Unknown Address',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),
                        const SizedBox(width: 5),
                        Text(
                          selectedPump['rating']?.toString() ?? 'N/A',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${distance.toStringAsFixed(1)} km",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Delivery Address Card
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
                      "DELIVERY ADDRESS",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      address.isNotEmpty ? address : 'Address not specified',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Distance warning or Confirm button
              if (!isWithinDistance)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red[900]!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    "Delivery not available for distances over 15 km",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (isWithinDistance)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      "CONFIRM ORDER",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.orange : Colors.white,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
