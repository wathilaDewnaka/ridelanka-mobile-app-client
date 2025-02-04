import 'package:client/firebase_options.dart';
import 'package:client/global_variable.dart';
import 'package:client/src/screens/auth/mobile_login_screen.dart';
import 'package:client/src/screens/auth/mobile_register_screen.dart';
import 'package:client/src/screens/auth/splash_screen.dart';
import 'package:client/src/screens/driver/driver_dashboard.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:client/src/screens/rider/vehicle_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  firebaseUser = FirebaseAuth.instance.currentUser;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white, // Set background to white
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        primarySwatch: Colors.blue, // Set a default color for the app
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        MobileRegisterScreen.id: (context) => const MobileRegisterScreen(),
        MobileLoginScreen.id: (context) => const MobileLoginScreen(),
        RiderNavigationMenu.id: (context) => const RiderNavigationMenu(),
        VehicleDetails.id: (context) => VehicleDetails(),
        DriverDashboard.id: (context) => const DriverDashboard()
      },
    );
  }
}
