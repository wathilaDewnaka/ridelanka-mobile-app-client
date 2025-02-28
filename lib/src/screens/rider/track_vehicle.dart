import 'dart:async';

import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/models/direction_details.dart';
import 'package:client/src/widgets/brand_divier.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackVehicle extends StatefulWidget {
  const TrackVehicle({super.key});

  @override
  State<TrackVehicle> createState() => _TrackVehicleState();
}

class _TrackVehicleState extends State<TrackVehicle> {
  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();

  Position? currentPosition;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  BitmapDescriptor? vehicleIcon;

  StreamSubscription<DatabaseEvent>? _driverLocationSubscription;

  String driverRideStatus = "Driver is Comming";

  DirectionDetails? tripDirectionDetails;

  String? _driverName;
  String? _vehicleDescription;

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

  void _setMapMarker(LatLng position) {
    setState(() {
      _Markers.add(
        Marker(
          markerId: MarkerId("currentLocation"),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      );
    });
  }

  Future<void> getCurrentPosition() async {
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

      // Set marker for current location
      _setMapMarker(pos);
    } catch (e) {
      print('Error while getting location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getDriverDetails();
    createMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 210,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          markers: _Markers,
          polylines: _polylines,
          circles: _Circles,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) async {
            _controller.complete(controller);
            mapController = controller;
            await getCurrentPosition();
            listenToDriverLocation(driverId);
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status of the ride
                  Center(
                    child: Text(
                      driverRideStatus,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, // Add overflow handling
                      maxLines: 1, // Force single line
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  BrandDivier(),

                  const SizedBox(height: 20.0),

                  // Modified car model text - Left-aligned
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _vehicleDescription ?? 'n/a',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // Modified driver name text - Left-aligned
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _driverName ?? 'n/a',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  BrandDivier(),

                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void listenToDriverLocation(String driverId) {
    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref()
        .child('driversAvailable')
        .child(driverId)
        .child('l');

    _driverLocationSubscription = driverRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<dynamic> location = event.snapshot.value as List<dynamic>;
        double latitude = location[0];
        double longitude = location[1];

        print(
            'Driver $driverId location updated: Lat: $latitude, Lng: $longitude');

        // Create LatLng object for driver location
        LatLng driverLocation = LatLng(latitude, longitude);

        drawPolyline(driverLocation);
        updateArrivalTimeToUserPickupLocation(driverLocation);
      }
    });
  }

  void drawPolyline(LatLng driverLocation) async {
    // Use current position as destination (if available)
    print("draw line");
    if (currentPosition == null) {
      print('Current position not available yet');
      //await Future.delayed(Duration(milliseconds: 500));
      return;
    }

    print("not return");
    LatLng currentLocationLatLng =
        LatLng(currentPosition!.latitude, currentPosition!.longitude);

    // Clear previous polylines
    _polylines.clear();

    // showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext context) =>
    //         ProgressDialog(status: 'Please wait...'));

    var thisDetails = await HelperMethods.getDirectionDetails(
        driverLocation, currentLocationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    //Navigator.pop(context);

    print("print details");
    print(thisDetails?.encodedPoints);

    if (thisDetails != null) {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> results =
          polylinePoints.decodePolyline(thisDetails.encodedPoints);

      polylineCoordinates.clear();

      if (results.isNotEmpty) {
        results.forEach((PointLatLng point) =>
            {polylineCoordinates.add(LatLng(point.latitude, point.longitude))});
      }

      // Create a list of coordinates for the polyline
      //polylineCoordinates = [driverLocation, currentLocationLatLng];

      setState(() {
        Polyline polyline = Polyline(
          polylineId: PolylineId('polyid'),
          color: Color(0xFF0051ED),
          points: polylineCoordinates,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );

        _polylines.add(polyline);
      });

      // Calculate bounds to fit the polyline on map
      LatLngBounds bounds;
      if (driverLocation.latitude > currentLocationLatLng.latitude &&
          driverLocation.longitude > currentLocationLatLng.longitude) {
        bounds = LatLngBounds(
            southwest: currentLocationLatLng, northeast: driverLocation);
      } else if (driverLocation.longitude > currentLocationLatLng.longitude) {
        bounds = LatLngBounds(
          southwest:
              LatLng(driverLocation.latitude, currentLocationLatLng.longitude),
          northeast:
              LatLng(currentLocationLatLng.latitude, driverLocation.longitude),
        );
      } else if (driverLocation.latitude > currentLocationLatLng.latitude) {
        bounds = LatLngBounds(
          southwest:
              LatLng(currentLocationLatLng.latitude, driverLocation.longitude),
          northeast:
              LatLng(driverLocation.latitude, currentLocationLatLng.longitude),
        );
      } else {
        bounds = LatLngBounds(
            southwest: driverLocation, northeast: currentLocationLatLng);
      }

      // Animate camera to show the complete route
      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

      // Add markers for driver and current location
      setState(() {
        // Clear existing markers if needed
        _Markers.removeWhere((marker) =>
            marker.markerId.value == "driverLocation" ||
            marker.markerId.value == "currentLocation");

        // Add driver location marker
        _Markers.add(Marker(
          markerId: MarkerId('driverLocation'),
          position: driverLocation,
          icon: vehicleIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow:
              InfoWindow(title: "Driver Location", snippet: 'Driver is here'),
        ));

        // Add current location marker
        _Markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: currentLocationLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow:
              InfoWindow(title: "Your Location", snippet: 'You are here'),
        ));
      });

      // Add circles for driver and current location
      setState(() {
        _Circles.clear();

        _Circles.add(Circle(
          circleId: CircleId('driverLocation'),
          strokeColor: Colors.blue,
          strokeWidth: 3,
          radius: 12,
          center: driverLocation,
          fillColor: Colors.blue.withOpacity(0.5),
        ));

        _Circles.add(Circle(
          circleId: CircleId('currentLocation'),
          strokeColor: Colors.green,
          strokeWidth: 3,
          radius: 12,
          center: currentLocationLatLng,
          fillColor: Color(0xFF40cf89),
        ));
      });
    }
  }

  Future<void> createMarker() async {
    if (vehicleIcon == null) {
      ImageConfiguration imageConfiguration = ImageConfiguration();

      try {
        BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
            imageConfiguration, 'assets/images/vehicle_icon/van-icon.png');

        await Future.delayed(
            Duration(seconds: 1)); // Optional delay for debugging

        setState(() {
          vehicleIcon = icon;
          print('icon is set');
        });
      } catch (e) {
        print("Error loading marker icon: $e");
      }
    }
  }

  

  void updateArrivalTimeToUserPickupLocation(
      driverCurrentPositionLatLng) async {
    LatLng userPickupPosition =
        LatLng(currentPosition!.latitude, currentPosition!.longitude);

    var directionDetailsInfo = await HelperMethods.getDirectionDetails(
        driverCurrentPositionLatLng, userPickupPosition);

    if (directionDetailsInfo == null) {
      return;
    }

    double distance = directionDetailsInfo.distanceValue.toDouble();
    if (distance < 100) {
      setState(() {
        driverRideStatus = "Driver has arrived";
      });
      return;
    }

    setState(() {
      driverRideStatus =
          "Driver is coming :: " + directionDetailsInfo.durationText.toString();
    });
  }

  Future<void> getDriverDetails() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('drivers').child(driverId);

    try {
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic> driverData =
            snapshot.value as Map<dynamic, dynamic>;

        String driverName = driverData['fullname'] ?? 'Unknown';
        String vehicleName = driverData['vehicleName'] ?? 'Unknown';
        String vehicleType = driverData['vehicleType'] ?? 'Unknown';

        print("Driver Name: $driverName");
        print("Vehicle Name: $vehicleName");
        print("Vehicle Type: $vehicleType");

        setState(() {
          _driverName = driverName;
          _vehicleDescription = vehicleName + ', ' + vehicleType;
        });
      } else {
        print("Driver not found.");
      }
    } catch (e) {
      print("Error fetching driver details: $e");
    }
  }
}
