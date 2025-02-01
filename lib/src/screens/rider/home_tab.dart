import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  double mapBottomPadding = 0;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  List<LatLng> polylineCoordinates = [];

  late Position currentPosition;
  var geoLocator = Geolocator();

  static final CameraPosition _initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }
  }

  void _setUpPositionLocator() async {
    await _checkPermissions();

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      setState(() {
        currentPosition = position;
      });

      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition = CameraPosition(target: pos, zoom: 17);

      mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      print('Current Position: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error while getting location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _setUpPositionLocator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _initialLocation,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;

              setState(() {
                mapBottomPadding = 280;
              });

              _setUpPositionLocator();
            },
          ),
        ],
      ),
    );
  }
}
