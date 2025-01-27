import 'package:client/firebase_options.dart';
import 'package:client/src/screens/auth/mobile_register_screen.dart';
import 'package:client/src/screens/auth/splash_screen.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const MobileRegisterScreen(), // Onboarding screen
    );
  }
}
