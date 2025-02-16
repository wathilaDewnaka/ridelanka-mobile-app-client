import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/screens/auth/on_board_screen.dart';
import 'package:client/src/screens/driver/driver_dashboard.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String id = "splash";

  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _navigateBasedOnUser();
  }

  Future<void> _navigateBasedOnUser() async {
    if (firebaseUser == null) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnBoardScreen()),
        );
      });
    } else {
      bool isPassenger = await HelperMethods.checkIsPassenger(firebaseUser!.uid);

      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => isPassenger
                ? const RiderNavigationMenu(selectedIndex: 0)
                : const DriverDashboard() 
                // : const RiderNavigationMenu(selectedIndex: 0)
                ,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color(0xFF0051ED),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              "assets/images/splash_screen/van.png",
              width: 325,
              height: 220,
              fit: BoxFit.cover,
            ),
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
