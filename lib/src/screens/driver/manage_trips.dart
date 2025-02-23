import 'dart:async';

import 'package:client/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFd16608),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Start Trip",
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
}
