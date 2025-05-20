import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_drawer.dart';
import 'profile.dart';
import 'Afterupdate/order_page.dart';
import 'Afterupdate/more_page.dart';
import 'menu/fuel_stations.dart';

class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String? selectedFuel;
  String selectedPrice = "";
  late StreamSubscription<DocumentSnapshot> fuelPriceSubscription;
  Map<String, String> fuelPrices = {"Petrol": "Fetching", "Diesel": "Fetching"};
  bool isLoading = true;
  bool showPrice = false;

  @override
  void initState() {
    super.initState();
    fetchFuelPrices();
  }

  void fetchFuelPrices() {
    fuelPriceSubscription = FirebaseFirestore.instance
        .collection("fuelPrices")
        .doc("latestPrices")
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            setState(() {
              fuelPrices["Petrol"] = "₹${snapshot.get("petrol")}/L";
              fuelPrices["Diesel"] = "₹${snapshot.get("diesel")}/L";
              isLoading = false;
            });
          }
        });
  }

  @override
  void dispose() {
    fuelPriceSubscription.cancel();
    super.dispose();
  }

  void updateFuelSelection(String fuelType) {
    setState(() {
      selectedFuel = fuelType;
      selectedPrice = fuelPrices[fuelType] ?? "Fetching...";
      showPrice = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              "Rapid Fil",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: Builder(
              builder:
                  (context) => IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.orangeAccent,
                      size: 30,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  size: 30,
                  color: Colors.orangeAccent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
            ],
            elevation: 0,
          ),
          drawer: MenuDrawer(),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  "Today's Fuel Prices",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFuelTypeCard("Petrol"),
                    _buildFuelTypeCard("Diesel"),
                  ],
                ),
                if (showPrice) ...[
                  SizedBox(height: 40),
                  _buildPriceDisplayCard(),
                ],
                SizedBox(height: 20),
                _buildInfoText(),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildFuelTypeCard(String type) {
    bool isSelected = selectedFuel == type;
    return GestureDetector(
      onTap: () => updateFuelSelection(type),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 160,
        height: 180,
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.orangeAccent.withOpacity(0.2)
                  : Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(color: Colors.orangeAccent, width: 2)
                  : Border.all(color: Colors.grey[800]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[850],
              ),
              child: Icon(
                Icons.local_gas_station,
                size: 40,
                color: isSelected ? Colors.orangeAccent : Colors.grey[400],
              ),
            ),
            SizedBox(height: 16),
            Text(
              type,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.orangeAccent : Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(height: 8),
            Text(
              fuelPrices[type] ?? "Fetching...",
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDisplayCard() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[900]!, Colors.black],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Current ${selectedFuel} Price",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 16),
          isLoading
              ? SizedBox(
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.orangeAccent,
                    strokeWidth: 3,
                  ),
                ),
              )
              : Text(
                selectedPrice,
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
          SizedBox(height: 10),
          Divider(color: Colors.grey[800], thickness: 1, height: 20),
          SizedBox(height: 10),
          Text(
            "Prices updated daily",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Tap on a fuel type to view detailed pricing information. "
        "Prices update by daily.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[850]!, width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.orangeAccent.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                shape: BoxShape.circle,
              ),
              child: Text(
                "₹",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            label: "Price",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket, size: 26),
            label: "Order",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_open, size: 26),
            label: "More",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 26),
            label: "Map",
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MorePage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FuelStationsPage()),
              );
              break;
          }
        },
      ),
    );
  }
}
