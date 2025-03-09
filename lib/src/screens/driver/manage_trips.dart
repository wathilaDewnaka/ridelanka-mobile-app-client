import 'dart:async';

import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/methods/push_notification_service.dart';
import 'package:client/src/models/driver.dart';
import 'package:client/src/screens/driver/attendance_dashboard.dart';
import 'package:client/src/widgets/confirm_sheet.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RidesTab extends StatefulWidget {
  @override
  State<RidesTab> createState() => _RidesTabState();
}

class _RidesTabState extends State<RidesTab> {
  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();

  var geoLocator = Geolocator();
  DatabaseReference? tripRequestRef;

  String availabilityTitle = 'START TRIP';
  Color availabilityColor = Color(0xFFd16608);

  bool isAvailable = false;

  Future<void> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle appropriately.
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle appropriately.
      print('Location permissions are permanently denied');
      return;
    }
  }

  void getCurrentPosition() async {
    await checkPermissions();

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      currentPosition = position;

      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition = CameraPosition(target: pos, zoom: 18);

      mapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      print('Current Position: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error while getting location: $e');
    }
  }

  void getCurrentDriverInfo() async {
    // Get the current user
    var firebase_user = FirebaseAuth.instance.currentUser;

    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child('drivers/${firebaseUser?.uid}');

    driverRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        print("Driver info");
        print(currentDriverInfo);
      }
    });

    if (firebase_user != null) {
      firebaseUser = firebase_user;
      print("user info");
      print(firebaseUser);
    }
  }

  void initalizeTheAttendance() async {
    DatabaseReference bookingsRef = FirebaseDatabase.instance
        .ref()
        .child("drivers/${firebaseUser!.uid}/bookings");

    bookingsRef.once().then((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> bookings =
            snapshot.snapshot.value as Map<dynamic, dynamic>;

        bookings.forEach((uid, bookingData) {
          bookingsRef.child(uid).update({"marked": "not_marked"});
        });
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
      await pref.setString(
          uid, DateTime.now().microsecondsSinceEpoch.toString());

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

  void getPreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    String sha = prefs.getString("online") ?? "false";
    if (sha == "true") {
      getLocationUpdate();

      setState(() {
        availabilityColor = Color(0xFF40cf89);
        availabilityTitle = 'END TRIP';
        isAvailable = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
    getPreviousState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF0051ED),
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () {
                  if (!isAvailable) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
                        title: "Error",
                        message: "Cannot go to back until trip ends",
                        type: MessageType.error));
                  }
                },
              ),
              elevation: 0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 17.0),
              child: Text(
                "Manage Trip",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: isAvailable
                ? EdgeInsets.only(top: 250)
                : EdgeInsets.only(top: 135),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: googlePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              getCurrentPosition();
            },
          ),
          Container(
            height: 235,
            width: double.infinity,
            color: Color(0xFF0e1526),
          ),
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 230,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        builder: (BuildContext context) => Confirmsheet(
                          title: (!isAvailable) ? 'START TRIP' : 'END TRIP',
                          subtitle: (!isAvailable)
                              ? 'You are about to became available be online'
                              : 'You will stop being online',
                          onPressed: () {
                            if (!isAvailable) {
                              initalizeTheAttendance();
                              startTrip();
                              getLocationUpdate();
                              Navigator.pop(context);

                              setState(() {
                                availabilityColor = Color(0xFF40cf89);
                                availabilityTitle = 'END TRIP';
                                isAvailable = true;
                              });
                            } else {
                              endTrip();
                              Navigator.pop(context);

                              setState(() {
                                availabilityColor = Color(0xFFd16608);
                                availabilityTitle = 'START TRIP';
                                isAvailable = false;
                              });
                            }
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: availabilityColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      (!isAvailable) ? 'START TRIP' : 'END TRIP',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isAvailable)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 230,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AttendancePage(isAttendance: true)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: availabilityColor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Mark Attendance",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 230,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AttendancePage(isAttendance: false)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: availabilityColor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "View Users",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  void startTrip() async {
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(firebaseUser!.uid, currentPosition!.latitude,
        currentPosition!.longitude);

    tripRequestRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/trip');
    tripRequestRef?.set('online');

    final prefs = await SharedPreferences.getInstance();
    final service = FlutterBackgroundService();

    await prefs.setString('online', "true");
    await prefs.setString("driverId", firebaseUser!.uid);

    service.startService();

    tripRequestRef?.onValue.listen((event) {});
  }

  void endTrip() async {
    Geofire.removeLocation(firebaseUser!.uid);
    tripRequestRef?.onDisconnect();
    tripRequestRef?.remove();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('online', "false");

    FlutterBackgroundService().invoke("stop");

    tripRequestRef = null;
  }

  void getLocationUpdate() {
    homeTabPositionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 4,
      ),
    ).listen((Position position) {
      // Handle location updates
      if (position != null) {
        sendDropNotification(LatLng(position.latitude, position.longitude));
        if (mounted) {
          setState(() {
            currentPosition = position;

            if (isAvailable) {
              Geofire.setLocation(
                  firebaseUser!.uid, position.latitude, position.longitude);
            }

            LatLng pos = LatLng(position.latitude, position.longitude);
            CameraPosition cameraPosition =
                CameraPosition(target: pos, zoom: 18);

            mapController!
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          });
        }
      }
    });
  }
}
