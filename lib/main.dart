import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:client/firebase_options.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/methods/push_notification_service.dart';
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
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  firebaseUser = FirebaseAuth.instance.currentUser;
  await requestPermissions();
  await initializeService();

  AwesomeNotifications().initialize(
    'resource://drawable/van',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF0051ED),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
    ),
  );
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

        try {
          sendDropNotification(LatLng(position.latitude, position.longitude));
        } catch (e) {
          print(e);
        }
      } catch (e) {
        print("Error cause :(");
        print(e.toString());
      }
    }
  });
}

void sendDropNotification(LatLng position) async {
  DatabaseReference bookingsRef = FirebaseDatabase.instance
      .ref()
      .child("drivers/${firebaseUser!.uid}/bookings");

  bookingsRef.once().then((snapshot) {
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> bookings =
          snapshot.snapshot.value as Map<dynamic, dynamic>;

      bookings.forEach((bookingId, bookingData) {
        int distance = HelperMethods.haversine(
            position,
            LatLng(bookingData['location']['endLat'],
                bookingData['location']['endLng']));
        if (distance <= 0.5) {
          sendNotification(bookingData['uId']);
        }
      });
    }
  });
}

Future<int> calculateDaysPassed(String uid) async {
  final pref = await SharedPreferences.getInstance();
  String? time = pref.getString(uid);

  if (time != null) {
    int timestampInMicros = int.parse(time);
    DateTime storedDate =
        DateTime.fromMillisecondsSinceEpoch(timestampInMicros ~/ 1000);
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(storedDate);
    return difference.inMinutes;
  } else {
    return 999;
  }
}

void sendNotification(String uid) async {
  int time = await calculateDaysPassed(uid);
  final pref = await SharedPreferences.getInstance();

  if (time >= 10) {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref("users/$uid/notifications");
    await databaseReference.push().set({
      "title": "Driver nearby drop",
      "description": "Driver nearby the drop location",
      "icon": "tick",
      "date": DateTime.now().microsecondsSinceEpoch.toString(),
      "isRead": "false",
      "isActive": ""
    });
    await pref.setString(uid, DateTime.now().microsecondsSinceEpoch.toString());

    try {
      DatabaseReference fcm =
          FirebaseDatabase.instance.ref().child("users/$uid/token");
      DataSnapshot snapshot = await fcm.get();
      String token = snapshot.value as String;
      PushNotificationService.sendNotificationsToUsers(
          token, "User Dropped Up", "User has been dropped by the driver");
    } catch (e) {
      print(e);
    }
  }
}

Future<void> requestPermissions() async {
  PermissionStatus locationStatus = await Permission.location.status;
  if (!locationStatus.isGranted) {
    await Permission.location.request();
  }

  PermissionStatus notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    await Permission.notification.request();
  }

  PermissionStatus backgroundStatus =
      await Permission.accessMediaLocation.status;
  if (!backgroundStatus.isGranted) {
    await Permission.accessMediaLocation.request();
  }
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

