import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show pi, sin, cos, sqrt, atan2;

import 'order_summary.dart';

class ConfirmLocation extends StatefulWidget {
  final String address;
  final LatLng userLocation;
  final List<String>? pumpLinks;
  final Map<String, dynamic> fuelSelectionData;
  final String orderId;

  const ConfirmLocation({
    Key? key,
    required this.address,
    required this.userLocation,
    this.pumpLinks,
    required this.fuelSelectionData,
    required this.orderId,
  }) : super(key: key);

  @override
  State<ConfirmLocation> createState() => _ConfirmLocationState();
}

class _ConfirmLocationState extends State<ConfirmLocation> {
  int? selectedPumpIndex;
  late GoogleMapController mapController;

  final List<Map<String, dynamic>> defaultPumps = [
    {
      'name': 'Samudra Fuel Centre - Hindustan Petroleum',
      'location': const LatLng(8.548284, 76.974113),
      'brand': 'Hindustan Petroleum',
      'address': 'karakulam, Thiruvananthapuram, Kerala 695004',
      'rating': 4.2,
      'open': true,
      'services': ['24/7', 'Lubricants', 'Tyre Air'],
    },
    {
      'name': 'MELATHIL FUELS, IOC Petrol Pump',
      'location': const LatLng(8.5779744, 76.9965165),
      'brand': 'Indian Oil',
      'address': 'karakulam, Thiruvananthapuram, Kerala 695004',
      'rating': 4.0,
      'open': true,
      'services': ['24/7', 'ATM', 'Convenience Store'],
    },
    {
      'name': 'IndianOil - Kazhakuttom',
      'location': const LatLng(8.6788224, 76.9043366),
      'brand': 'Indian Oil',
      'address': 'venjaramoodu, Thiruvananthapuram, Kerala 695582',
      'rating': 4.1,
      'open': true,
      'services': ['24/7', 'CNG', 'Lubricants'],
    },
    {
      'name': 'NAYARA ENERGY (MOOLAYIL FUELS)',
      'location': const LatLng(8.6287346, 76.9603386),
      'brand': 'Nayara Energy',
      'address': 'Theakkada, Vembayam, Thiruvananthapuram, Kerala 695615',
      'rating': 3.9,
      'open': true,
      'services': ['24/7', 'Lubricants', 'Tyre Air'],
    },
    {
      'name': 'IndianOil - Pattom',
      'location': const LatLng(8.5516141, 76.989642),
      'brand': 'Indian Oil',
      'address': 'kachani, Thiruvananthapuram, Kerala 695004',
      'rating': 4.3,
      'open': true,
      'services': ['24/7', 'ATM', 'Convenience Store'],
    },
    {
      'name': 'IndianOil - Sreekaryam',
      'location': const LatLng(8.5566191, 76.943321),
      'brand': 'Indian Oil',
      'address': 'Manathala, Thiruvananthapuram, Kerala 695017',
      'rating': 4.0,
      'open': true,
      'services': ['Lubricants', 'Tyre Air'],
    },
  ];

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // in kilometers

    double lat1 = start.latitude;
    double lon1 = start.longitude;
    double lat2 = end.latitude;
    double lon2 = end.longitude;

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  Set<Marker> _createMarkers() {
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId("userLocation"),
        position: widget.userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    };

    if (selectedPumpIndex != null) {
      final selectedPump = defaultPumps[selectedPumpIndex!];
      markers.add(
        Marker(
          markerId: const MarkerId("selectedPump"),
          position: selectedPump['location'] as LatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: selectedPump['name'] as String),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _createCircles() {
    return {
      Circle(
        circleId: const CircleId("userLocationRadius"),
        center: widget.userLocation,
        radius: 15000, // 15 km in meters
        strokeWidth: 2,
        strokeColor: Colors.orange,
        fillColor: Colors.orange.withOpacity(0.1),
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _centerMapOnPump(LatLng location) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(location, 12));
  }

  void _proceedWithOrder() {
    if (selectedPumpIndex == null) return;

    final selectedPump = defaultPumps[selectedPumpIndex!];
    double distanceInKm = calculateDistance(
      widget.userLocation,
      selectedPump['location'] as LatLng,
    );
    distanceInKm = double.parse(distanceInKm.toStringAsFixed(2));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderSummaryPage(
              orderId: widget.orderId,
              fuelSelectionData: widget.fuelSelectionData,
              selectedPump: selectedPump,
              userLocation: widget.userLocation,
              distanceInKm: distanceInKm,
              address: widget.address,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Confirm Delivery Location",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Section
              _buildSectionHeader("select inside the zone area"),
              const SizedBox(height: 12),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: widget.userLocation,
                      zoom: 12,
                    ),
                    markers: _createMarkers(),
                    circles: _createCircles(),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Address Section
              _buildSectionHeader("Delivery Address"),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CONFIRMED ADDRESS:",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.address,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pump Selection Section
              _buildSectionHeader(
                "Available Fuel Pumps (${defaultPumps.length})",
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: defaultPumps.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final pump = defaultPumps[index];
                    return _buildPumpCard(pump, index);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      selectedPumpIndex == null ? null : _proceedWithOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                    shadowColor: Colors.orange.withOpacity(0.5),
                  ),
                  child: const Text(
                    "CONFIRM & PROCEED",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildPumpCard(Map<String, dynamic> pump, int index) {
    return Card(
      color: Colors.grey[900],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selectedPumpIndex == index ? Colors.orange : Colors.grey[700]!,
          width: selectedPumpIndex == index ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            selectedPumpIndex = index;
            _centerMapOnPump(pump['location'] as LatLng);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        selectedPumpIndex == index
                            ? Colors.orange
                            : Colors.grey[600]!,
                    width: 2,
                  ),
                ),
                child:
                    selectedPumpIndex == index
                        ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.orange,
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pump['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pump['address'] as String,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          (pump['rating'] as double).toString(),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (pump['services'] != null)
                          ...(pump['services'] as List<String>)
                              .take(2)
                              .map(
                                (service) => Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      service,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${calculateDistance(widget.userLocation, pump['location'] as LatLng).toStringAsFixed(1)} km',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (pump['open'] as bool)
                              ? Colors.green[900]
                              : Colors.red[900],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (pump['open'] as bool) ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        color:
                            (pump['open'] as bool) ? Colors.green : Colors.red,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
