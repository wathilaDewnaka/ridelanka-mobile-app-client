import 'dart:async';

import 'package:client/global_variable.dart';
import 'package:client/src/models/driver.dart';
import 'package:client/src/widgets/confirm_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
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
          height: 135,
          width: double.infinity,
          color: Color(0xFF0e1526),
        ),
        Positioned(
          top: 60,
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
                            startTrip();
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
        )
      ],
    );
  }

  void startTrip() {
    print("this is user");
    print(firebaseUser);
    print("this is position");
    print(currentPosition);

    Geofire.initialize('driversAvailable');
    Geofire.setLocation(firebaseUser!.uid, currentPosition!.latitude,
        currentPosition!.longitude);

    tripRequestRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/trip');
    tripRequestRef?.set('online');

    tripRequestRef?.onValue.listen((event) {});
  }

  void endTrip() {
    Geofire.removeLocation(firebaseUser!.uid);
    tripRequestRef?.onDisconnect();
    tripRequestRef?.remove();
    tripRequestRef = null;
  }
}
