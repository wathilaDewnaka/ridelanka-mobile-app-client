import 'package:client/src/screens/auth/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white, // Set background to white
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        primarySwatch: Colors.blue, // Set a default color for the app
      ),
      home: const SplashScreen(), // Onboarding screen
    );
  }
}
