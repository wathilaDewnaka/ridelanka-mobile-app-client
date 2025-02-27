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

  

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
