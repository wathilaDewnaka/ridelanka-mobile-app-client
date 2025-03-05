import 'dart:async';
import 'dart:ui';

import 'package:client/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:client/src/screens/driver/driver_dashboard.dart';
import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/screens/auth/mobile_register_screen.dart';
import 'package:client/src/screens/auth/splash_screen.dart';
import 'package:client/global_variable.dart';
import 'package:client/src/screens/auth/mobile_login_screen.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  firebaseUser = FirebaseAuth.instance.currentUser;
  await initializeService();

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "RideLanka Tracking",
      content: "Your location is being tracked",
    );
  }

  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background process is now stopped");
  });

  Timer.periodic(const Duration(seconds: 50), (timer) async {
    print("Testing 1");

    final pref = await SharedPreferences.getInstance();
    await pref.reload();

    String id = pref.getString("driverId") ?? "NaN";
    String isPassenger = pref.getString('isPassenger') ?? "true";
    String online = pref.getString("online") ?? "false";

    print("$id $isPassenger $online");

    if (id != "NaN" && isPassenger != "true" && online != "false") {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        );
        print(
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}");

        await Firebase.initializeApp();
        await FirebaseDatabase.instance.ref("driversAvailable/$id/l").update({
          "0": position.latitude,
          "1": position.longitude,
        });
      } catch (e) {
        print("Error cause :(");
        print(e.toString());
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppData(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            primarySwatch: Colors.blue,
          ),
          initialRoute: SplashScreen.id,
          routes: {
            SplashScreen.id: (context) => const SplashScreen(),
            MobileRegisterScreen.id: (context) => const MobileRegisterScreen(),
            MobileLoginScreen.id: (context) => const MobileLoginScreen(),
            RiderNavigationMenu.id: (context) =>
                const RiderNavigationMenu(selectedIndex: 0),
            DriverHome.id: (context) => const DriverHome()
          },
        ));
  }
}
