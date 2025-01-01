import 'package:client/src/auth/screens/on_board_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set immersive mode to hide the system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Navigate to OnBoardScreen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnBoardScreen()),
      );
    });
  }

  @override
  void dispose() {
    // Restore system UI overlays when splash screen is disposed
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose(); // Call the super.dispose method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color(0xFF0051ED), // Solid background color (#0051ED)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              "assets/images/splash_screen/van.png", // Ensure this path is correct
              height: 200,
            ),
            const SizedBox(height: 14), // Spacing between logo and text
            // App Name
            const Text(
              "RideLanka",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold, // Professional font style
              ),
            ),
          ],
        ),
      ),
    );
  }
}
