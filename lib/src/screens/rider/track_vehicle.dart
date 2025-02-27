import 'package:client/global_variable.dart';
import 'package:client/src/widgets/brand_divier.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackVehicle extends StatefulWidget {
  const TrackVehicle({super.key});

  @override
  State<TrackVehicle> createState() => _TrackVehicleState();
}

class _TrackVehicleState extends State<TrackVehicle> {

  GoogleMapController? mapController;
  Position? currentPosition;

  Set<Marker> _Markers = {};

  String driverRideStatus = "Driver is Comming";

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
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) async {
            mapController = controller;
            await getCurrentPosition();
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
                      "School Van",
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
                      "Nimshan Munasinhe",
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
}
