import 'dart:async';
import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/models/direction_details.dart';
import 'package:client/src/screens/rider/search_page.dart';
import 'package:client/src/screens/rider/vehicle_details.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  double mapBottomPadding = 0;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  late Position currentPosition;

  DirectionDetails? tripDirectionDetails;

  static final CameraPosition _initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Color customBlue = Color(0xFF0051ED);

  @override
  void initState() {
    super.initState();
    _setUpPositionLocator();
  }

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
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentPosition = position;
      });

      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition = CameraPosition(target: pos, zoom: 17);

      mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String address =
          await HelperMethods.findCordinateAddress(currentPosition, context);
      _setMapMarker(pos);
    } catch (e) {
      print('Error while getting location: $e');
    }
  }

  void _setMapMarker(LatLng position) {
    setState(() {
      _Markers.add(
        Marker(
          markerId: MarkerId("currentLocation"),
          position: position,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(
            top: 100,
            bottom: mapBottomPadding,
          ),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _initialLocation,
          markers: _Markers,
          polylines: _polylines,
          circles: _Circles,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;

            setState(() {
              mapBottomPadding = 185;
            });

            _setUpPositionLocator();
          },
        ),
        Positioned(
          top: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Provider.of<AppData>(context).pickupAddress?.placeName ??
                          "Pickup Location",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.close, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 15,
          right: 15,
          bottom: 20,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () async {
                    var response = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SearchPage()));

                    if (response == 'getDirection') {
                      print("res recieved");
                      var latestDestination =
                          Provider.of<AppData>(context, listen: false)
                              .destinationAddress;

                      await getDirection();

                      print("this is your Destination : ${latestDestination}");
                    }
                    print("This is Ditector after");
                    print("This is response");
                    print(response);
                    print("this is aafter res");
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            Provider.of<AppData>(context)
                                .destinationAddress
                                .placeName,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ),
                        Icon(Icons.search, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VehicleDetails(isStudent: true)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "School",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VehicleDetails(isStudent: false)));
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: customBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Staff",
                          style: TextStyle(color: customBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longituge);
    var destinationLatLng = LatLng(destination.latitude, destination.longituge);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Please wait...'));

    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

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

      _polylines.clear();

      setState(() {
        Polyline polyline = Polyline(
            polylineId: PolylineId('polyid'),
            color: Color(0xFF0051ED),
            points: polylineCoordinates,
            jointType: JointType.round,
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true);

        _polylines.add(polyline);
      });

      // make the polyline fit to the map
      LatLngBounds bounds;

      if (pickLatLng.latitude > destinationLatLng.latitude &&
          pickLatLng.longitude > destinationLatLng.longitude) {
        bounds =
            LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
      } else if (pickLatLng.longitude > destinationLatLng.longitude) {
        bounds = LatLngBounds(
            southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
            northeast:
                LatLng(destinationLatLng.latitude, pickLatLng.longitude));
      } else if (pickLatLng.latitude > destinationLatLng.latitude) {
        bounds = LatLngBounds(
            southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
            northeast:
                LatLng(pickLatLng.latitude, destinationLatLng.longitude));
      } else {
        bounds =
            LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
      }

      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

      Marker pickupMarker = Marker(
        markerId: MarkerId('pickup'),
        position: pickLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId('destination'),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow:
            InfoWindow(title: destination.placeName, snippet: 'Destination'),
      );

      setState(() {
        _Markers.add(pickupMarker);
        _Markers.add(destinationMarker);
      });

      Circle pickupCircle = Circle(
          circleId: CircleId('pickup'),
          strokeColor: Colors.green,
          strokeWidth: 3,
          radius: 12,
          center: pickLatLng,
          fillColor: Color(0xFF40cf89));

      Circle destinationCircle = Circle(
          circleId: CircleId('destination'),
          strokeColor: Color(0xFF4f5cd1),
          strokeWidth: 3,
          radius: 12,
          center: destinationLatLng,
          fillColor: Color(0xFF4f5cd1));

      setState(() {
        _Circles.add(pickupCircle);
        _Circles.add(destinationCircle);
      });
    }
  }
}
