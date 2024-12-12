import 'package:client/src/features/screens/on_board_screen.dart';
import 'package:client/src/features/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/features/screens/onboarding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Set background to white
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // Optional: Set the app bar background to white as well
        ),
        primarySwatch: Colors.blue, // Set a default color for the app
      ),
      home: const SplashScreen(), // Onboarding screen
    );
  }
}
