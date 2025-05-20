import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class FuelStationsPage extends StatefulWidget {
  @override
  _FuelStationsPageState createState() => _FuelStationsPageState();
}

class _FuelStationsPageState extends State<FuelStationsPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  LatLng highlightedLocation1 = LatLng(8.6788224, 76.9043366);
  String highlightedLocationLink1 =
      "https://www.google.com/maps/place/IndianOil/@8.6787749,76.9044215,21z/data=!4m6!3m5!1s0x3b05c15a1ca6c1ad:0xede742e677779fdb!8m2!3d8.6788224!4d76.9043366!16s%2Fg%2F11cn95hzwy?entry=ttu&g_ep=EgoyMDI1MDMxOS4yIKXMDSoASAFQAw%3D%3D";

  LatLng highlightedLocation2 = LatLng(8.548284, 76.974113);
  String highlightedLocationLink2 =
      "https://www.google.com/maps/place/Samudra+Fuel+Centre+-+Hindustan+Petroleum/@8.5484372,76.9736147,19.25z/data=!4m6!3m5!1s0x3b05b9a298d5f74d:0x45873093e9e3ad14!8m2!3d8.548284!4d76.974113!16s%2Fg%2F1tgplgd1?entry=ttu&g_ep=EgoyMDI1MDMxOS4yIKXMDSoASAFQAw%3D%3D";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    LatLng? location = await getUserLocation();
    if (location != null) {
      setState(() => _currentPosition = location);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
      List<Map<String, dynamic>> stations = await fetchNearbyFuelStations(
        location,
      );
      updateMarkers(stations);
    }

    setState(() {
      _markers.addAll([
        Marker(
          markerId: MarkerId("highlighted_location1"),
          position: highlightedLocation1,
          infoWindow: InfoWindow(
            title: "Indian Oil",
            snippet: "📍 Click for Directions",
            onTap: () async {
              if (await canLaunch(highlightedLocationLink1)) {
                await launch(highlightedLocationLink1);
              }
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: MarkerId("highlighted_location2"),
          position: highlightedLocation2,
          infoWindow: InfoWindow(
            title: "Samudra Fuel Centre",
            snippet: "📍 Click for Directions",
            onTap: () async {
              if (await canLaunch(highlightedLocationLink2)) {
                await launch(highlightedLocationLink2);
              }
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      ]);
    });
  }

  Future<LatLng?> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  Future<List<Map<String, dynamic>>> fetchNearbyFuelStations(
    LatLng userLocation,
  ) async {
    final String apiKey = "AIzaSyAWSlCJNmWoPYK4KFu3J-8uQHqfxjIa-g8";
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${userLocation.latitude},${userLocation.longitude}"
        "&radius=5000"
        "&type=gas_station"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["status"] == "OK"
          ? List<Map<String, dynamic>>.from(data["results"])
          : [];
    }
    return [];
  }

  void updateMarkers(List<Map<String, dynamic>> stations) {
    setState(() {
      _markers.clear();
      if (_currentPosition != null) {
        _markers.add(
          Marker(
            markerId: MarkerId("user_location"),
            position: _currentPosition!,
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }

      for (var station in stations) {
        LatLng location = LatLng(
          station["geometry"]["location"]["lat"],
          station["geometry"]["location"]["lng"],
        );
        _markers.add(
          Marker(
            markerId: MarkerId(station["place_id"]),
            position: location,
            infoWindow: InfoWindow(title: station["name"]),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 1),
          ),
          child: Stack(
            children: [
              _currentPosition == null
                  ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.orangeAccent,
                    ),
                  )
                  : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: highlightedLocation1,
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      Future.delayed(Duration(milliseconds: 500), () {
                        _mapController?.setMapStyle(_darkMapStyle);
                      });
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(highlightedLocation1, 15),
                      );
                    },
                  ),
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Rapid Fil",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Green marks indicate available refuel pumps.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(
                        255,
                        81,
                        255,
                        0,
                      ).withOpacity(0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#FF8C00"}]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry",
      "stylers": [{"color": "#A66A00"}]
    },
    {
      "featureType": "road.local",
      "elementType": "geometry",
      "stylers": [{"color": "#5C3D00"}]
    }
  ]
  ''';
}
