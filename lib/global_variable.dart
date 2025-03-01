import 'dart:async';

import 'package:client/src/models/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

User? firebaseUser;
String mapKey = 'AIzaSyAn78RjZUxRa0Dq71QscaEqMuhfXlXWqlE';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

StreamSubscription<Position>? homeTabPositionStream;

Position? currentPosition;

Driver? currentDriverInfo;

String driverId = 'E8AfWjrmhhR6iRPfAqGlLrRit5C3';

