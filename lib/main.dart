import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file is present
import 'loading_page.dart';
import 'registration_page.dart';
import 'login_page.dart';
import 'agreement_page.dart';
import 'warning.dart';
import 'update.dart';
import 'menu/orders.dart';
import 'menu/fuel_stations.dart';
import 'menu/track_delivery.dart';
import 'menu/payments.dart';
import 'menu/near_refuel_station.dart';
import 'menu/orders.dart'; // Make sure to import your OrderPage
import 'placeorder/feedbackes.dart'; // Make sure to import your FeedbackPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ensure system UI overlays are edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Set status bar and navigation bar colors
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Black status bar
      statusBarIconBrightness: Brightness.light, // White icons
      systemNavigationBarColor: Colors.black, // Black navigation bar
      systemNavigationBarIconBrightness: Brightness.light, // White icons
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          hintStyle: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 45),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingPage(),
        '/register': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(),
        '/agreement': (context) => AgreementPage(),
        '/warning': (context) => WarningPage(),
        '/update': (context) => UpdatePage(),
        '/orders': (context) => OrdersPage(),
        '/fuel_stations': (context) => FuelStationsPage(),
        '/track_delivery': (context) => TrackDeliveryPage(),
        '/payments': (context) => PaymentsPage(),
        '/near_refuel_pump': (context) => NearRefuelStationPage(),
        '/orderpage': (context) => OrdersPage(), // Added OrderPage route
        '/feedback': (context) {
          final orderId = ModalRoute.of(context)!.settings.arguments as String;
          return FeedbackPage(orderId: orderId);
        },
      },
    );
  }
}
