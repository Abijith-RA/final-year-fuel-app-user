import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:rapidfil/update.dart';
import 'package:rapidfil/placeorder/location.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  double fuelPrice = 0.0;
  double fuelQuantity = 1.0;
  String selectedFuelType = "Petrol";
  String selectedStation = "Emergency";
  Position? userLocation;
  double deliveryCharge = 0.0;
  double totalCost = 0.0;
  List<Map<String, dynamic>> nearbyStations = [];
  String? tyreService;
  double tyreServiceCharge = 0.0;
  bool isOrderPlaced = false;
  bool showNextButton = false;
  String? currentOrderId;
  int _cancelTimeLeft = 120; // 2 minutes in seconds
  Timer? _cancelTimer;
  Timer? _nextButtonTimer;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchFuelPrice();
    fetchUserLocation();
  }

  @override
  void dispose() {
    _cancelTimer?.cancel();
    _nextButtonTimer?.cancel();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!isOrderPlaced) {
      return true;
    }

    bool? shouldExit = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cancel Order?', style: TextStyle(color: Colors.red)),
            content: Text(
              'Going back will cancel your current order. Do you want to proceed?',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.grey[900],
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('NO', style: TextStyle(color: Colors.orange)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('EXIT', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (shouldExit == true) {
      await _transferOrderToCanceled();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => UpdatePage()),
        (Route<dynamic> route) => false,
      );
      return true;
    }
    return false;
  }

  Future<void> _transferOrderToCanceled() async {
    if (currentOrderId == null) return;

    try {
      DocumentSnapshot orderDoc =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(currentOrderId)
              .get();

      if (orderDoc.exists) {
        Map<String, dynamic> orderData =
            orderDoc.data() as Map<String, dynamic>;

        orderData['cancellationTimestamp'] = FieldValue.serverTimestamp();
        orderData['status'] = 'cancelled';
        orderData['cancelReason'] = 'User exited the order page';

        await FirebaseFirestore.instance
            .collection('canceledOrders')
            .doc(currentOrderId)
            .set(orderData);

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(currentOrderId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error cancelling order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void startCancelTimer() {
    _cancelTimer?.cancel();
    _cancelTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_cancelTimeLeft == 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            // Timer completed, no state changes needed
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _cancelTimeLeft--;
          });
        }
      }
    });
  }

  void startNextButtonTimer() {
    _nextButtonTimer?.cancel();
    _nextButtonTimer = Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showNextButton = true;
        });
      }
    });
  }

  void fetchUserData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    var userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
    if (userDoc.exists && mounted) {
      setState(() {
        nameController.text = userDoc['name'];
        phoneController.text = userDoc['phone'];
      });
    }
    }

  void fetchFuelPrice() async {
    var fuelDoc =
        await FirebaseFirestore.instance
            .collection('fuelPrices')
            .doc('latestPrices')
            .get();
    if (fuelDoc.exists && mounted) {
      setState(() {
        fuelPrice =
            selectedFuelType == "Petrol"
                ? fuelDoc['petrol']
                : fuelDoc['diesel'];
        calculateTotalCost();
      });
    }
  }

  void fetchUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        userLocation = position;
        findNearbyStations();
      });
    }
  }

  void findNearbyStations() async {
    if (userLocation == null) return;
    var stationsSnapshot =
        await FirebaseFirestore.instance.collection('fuelStations').get();
    List<Map<String, dynamic>> stations = [];
    for (var doc in stationsSnapshot.docs) {
      double stationLat = doc['latitude'];
      double stationLng = doc['longitude'];
      double distance =
          Geolocator.distanceBetween(
            userLocation!.latitude,
            userLocation!.longitude,
            stationLat,
            stationLng,
          ) /
          1000;
      stations.add({
        "name": doc['name'],
        "distance": distance,
        "latitude": stationLat,
        "longitude": stationLng,
      });
    }
    stations.sort((a, b) => a['distance'].compareTo(b['distance']));
    if (mounted) {
      setState(() {
        nearbyStations = stations.take(3).toList();
        calculateTotalCost();
      });
    }
  }

  void calculateTotalCost() {
    double fuelCost = fuelPrice * fuelQuantity;
    if (nearbyStations.isNotEmpty) {
      double distance = nearbyStations.first['distance'];
      deliveryCharge = distance * 20;
    }

    double totalTyreCharge =
        selectedStation == "Tyre Issue" ? tyreServiceCharge : 0.0;

    if (mounted) {
      setState(() {
        totalCost = fuelCost + deliveryCharge + totalTyreCharge;
      });
    }
  }

  void placeOrder() async {
    String orderId = Uuid().v4();
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    Map<String, dynamic> orderData = {
      "orderId": orderId,
      "userId": userId,
      "name": nameController.text,
      "phone": phoneController.text,
      "situation": selectedStation,
      "fuelType": selectedFuelType,
      "fuelQuantity": fuelQuantity,
      "deliveryCharge": deliveryCharge,
      "totalCost": totalCost,
      "timestamp": FieldValue.serverTimestamp(),
      "status": "active",
    };

    if (selectedStation == "Tyre Issue") {
      orderData["tyreService"] = tyreService;
      orderData["tyreServiceCharge"] = tyreServiceCharge;
    }

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .set(orderData);

    if (mounted) {
      setState(() {
        isOrderPlaced = true;
        currentOrderId = orderId;
        _cancelTimeLeft = 120;
      });
    }

    startCancelTimer();
    startNextButtonTimer();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order placed successfully!")));
    }
    }

  Future<void> cancelOrder() async {
    if (currentOrderId == null) return;

    try {
      await _transferOrderToCanceled();

      _cancelTimer?.cancel();
      _nextButtonTimer?.cancel();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => UpdatePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to cancel order: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.orangeAccent),
        filled: true,
        fillColor: Colors.black,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    Function(String?)? onChanged,
    bool enabled = true,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.orangeAccent),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
          onChanged: enabled ? onChanged : null,
          dropdownColor: Colors.black87,
          style: TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down, color: Colors.orangeAccent),
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Widget buildTyreServiceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDropdown(
          label: "Tyre Service",
          value: tyreService ?? "Stepney Replace",
          items: ["Stepney Replace", "Tyre Replace / Puncture Work"],
          onChanged:
              isOrderPlaced
                  ? null
                  : (String? value) {
                    if (mounted) {
                      setState(() {
                        tyreService = value!;
                        tyreServiceCharge =
                            (value == "Stepney Replace") ? 200.0 : 150.0;
                        calculateTotalCost();
                      });
                    }
                  },
          enabled: !isOrderPlaced,
        ),
        SizedBox(height: 10),
        Text(
          "Tyre Service Charge: ₹${tyreServiceCharge.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      ],
    );
  }

  Widget buildFuelQuantitySlider() {
    return Slider(
      value: fuelQuantity,
      min: 1,
      max: 12,
      divisions: 11,
      label: "$fuelQuantity L",
      activeColor: isOrderPlaced ? Colors.grey : Colors.orangeAccent,
      onChanged:
          isOrderPlaced
              ? null
              : (value) {
                if (mounted) {
                  setState(() {
                    fuelQuantity = value;
                    calculateTotalCost();
                  });
                }
              },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Order Page",
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  buildTextField(nameController, "Name"),
                  SizedBox(height: 10),
                  buildTextField(phoneController, "Phone"),
                  SizedBox(height: 20),
                  buildDropdown(
                    label: "Situation Type",
                    value: selectedStation,
                    items: ["Emergency", "Low Fuel", "Tyre Issue"],
                    onChanged:
                        isOrderPlaced
                            ? null
                            : (String? value) {
                              if (mounted) {
                                setState(() {
                                  selectedStation = value!;
                                  if (value == "Tyre Issue") {
                                    tyreService = "Stepney Replace";
                                    tyreServiceCharge = 200.0;
                                  } else {
                                    tyreService = null;
                                    tyreServiceCharge = 0.0;
                                  }
                                  calculateTotalCost();
                                });
                              }
                            },
                    enabled: !isOrderPlaced,
                  ),
                  SizedBox(height: 20),
                  if (selectedStation == "Tyre Issue")
                    buildTyreServiceDropdown(),
                  SizedBox(height: 20),
                  buildDropdown(
                    label: "Fuel Type",
                    value: selectedFuelType,
                    items: ["Petrol", "Diesel"],
                    onChanged:
                        isOrderPlaced
                            ? null
                            : (String? value) {
                              if (mounted) {
                                setState(() {
                                  selectedFuelType = value!;
                                  fetchFuelPrice();
                                });
                              }
                            },
                    enabled: !isOrderPlaced,
                  ),
                  SizedBox(height: 20),
                  buildFuelQuantitySlider(),
                  SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fuel Cost: ₹${(fuelPrice * fuelQuantity).toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      if (selectedStation == "Tyre Issue")
                        Text(
                          "Tyre Service: ₹${tyreServiceCharge.toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      SizedBox(height: 10),
                      Text(
                        "Total Cost: ₹${totalCost.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (!isOrderPlaced)
                    ElevatedButton(
                      onPressed: placeOrder,
                      child: Text("Place Order"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  if (isOrderPlaced && showNextButton)
                    ElevatedButton(
                      onPressed: () {
                        if (currentOrderId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UserLocation(
                                    orderId: currentOrderId!,
                                    fuelSelectionData: {
                                      'name': nameController.text,
                                      'phone': phoneController.text,
                                      'fuelType': selectedFuelType,
                                      'quantity': fuelQuantity,
                                      'totalCost': totalCost,
                                      'situation': selectedStation,
                                      'tyreService': tyreService,
                                      'tyreServiceCharge': tyreServiceCharge,
                                    },
                                  ),
                            ),
                          );
                        }
                      },
                      child: Text("Next"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 245, 160, 2),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  if (isOrderPlaced && _cancelTimeLeft > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: cancelOrder,
                          child: Text("Cancel Order"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 30,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (isOrderPlaced && _cancelTimeLeft > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        children: [
                          Text(
                            "Time left to cancel: ${_formatTime(_cancelTimeLeft)}",
                            style: TextStyle(
                              color:
                                  _cancelTimeLeft > 30
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          LinearProgressIndicator(
                            value: _cancelTimeLeft / 120,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _cancelTimeLeft > 30
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
