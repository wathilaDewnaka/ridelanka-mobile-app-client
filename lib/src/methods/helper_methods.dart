import 'dart:math';

import 'package:client/global_variable.dart';
import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/methods/request_helper.dart';
import 'package:client/src/models/address.dart';
import 'package:client/src/models/available_vehicles.dart';
import 'package:client/src/models/direction_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

class HelperMethods {
  static Future<String> findCordinateAddress(Position position, context) async {
    print("this is position ");
    print(position);
    String placeAddress = '';

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${mapKey}';

    var response = await RequestHelper.getRequest(url);
    
    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
      print('this is res :' + placeAddress);
      Address pickupAddress = Address(
          placeId: '',
          latitude: position.latitude,
          longituge: position.longitude,
          placeName: placeAddress,
          placeFormattedAddress: '');

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }

    return placeAddress;
  }

  static Future<String> returnPlaceAddress(LatLng position) async {
    String placeAddress = '';

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${mapKey}';

    var response = await RequestHelper.getRequest(url);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
    }

    return placeAddress;
  }

  static Future<DirectionDetails?> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?destination=${endPosition.latitude.toString()},${endPosition.longitude.toString()}&origin=${startPosition.latitude.toString()},${startPosition.longitude.toString()}&key=$mapKey&avoid=tolls';

    var response = await RequestHelper.getRequest(url);

    if (response == 'failed') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails(
        durationText: response['routes'][0]['legs'][0]['duration']['text'],
        durationValue: response['routes'][0]['legs'][0]['duration']['value'],
        distanceText: response['routes'][0]['legs'][0]['distance']['text'],
        distanceValue: response['routes'][0]['legs'][0]['distance']['value'],
        encodedPoints: response['routes'][0]['overview_polyline']['points']);

    return directionDetails;
  }

  static Future<bool> checkPhoneNumberExists(
      String phoneNumber, bool isPassenger) async {
    final databaseReference = (isPassenger)
        ? FirebaseDatabase.instance.ref("users")
        : FirebaseDatabase.instance.ref("drivers");

    try {
      final snapshot = await databaseReference
          .orderByChild("phone")
          .equalTo(phoneNumber)
          .get();

      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  static Future<bool> checkPhoneAndEmail(
      String phoneNumber, String email, bool isPassenger) async {
    final databaseReference = (isPassenger)
        ? FirebaseDatabase.instance.ref("users")
        : FirebaseDatabase.instance.ref("drivers");

    try {
      final snapshot = await databaseReference
          .orderByChild("phone")
          .equalTo(phoneNumber)
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        bool emailMatches = false;

        data.forEach((key, value) {
          if (value['email'] == email) {
            emailMatches = true;
          }
        });
        return emailMatches;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  static Future<bool> checkIsPassenger(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");

    try {
      DatabaseEvent event = await ref.once();
      return event.snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchVehicleDetails(
      bool isStudent) async {
    try {
      final DatabaseEvent event =
          await FirebaseDatabase.instance.ref('drivers').once();
      final data = event.snapshot.value;

      if (data != null) {
        Map<String, dynamic> driversData = {};

        // Check if the data is a Map<Object?, Object?> and manually convert it
        if (data is Map<Object?, Object?>) {
          driversData = Map<String, dynamic>.fromIterable(
            data.keys,
            key: (key) => key.toString(),
            value: (key) =>
                Map<String, dynamic>.from(data[key] as Map<Object?, Object?>),
          );
        } else {
          print("Data is not a Map, cannot convert");
          return null;
        }

        Map<String, dynamic> filteredDetails = {};

        // Process each driver data
        driversData.forEach((uid, driverData) {
          final type = driverData['type'];
          final location = driverData['location'];

          if ((isStudent && type == 'student') ||
              (!isStudent && type == 'staff')) {
            if (location != null) {
              filteredDetails[uid] = {
                'startLat': location['startLat'],
                'startLng': location['startLng'],
                'endLat': location['endLat'],
                'endLng': location['endLng']
              };
            }
          }
        });

        return filteredDetails;
      } else {
        print('No data available for any drivers.');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  static Future<List<AvailableVehicles>> findNearestVehicles(
      BuildContext context, bool isStudent) async {
    final vehiclesDetails = await fetchVehicleDetails(isStudent);
    if (vehiclesDetails == null) {
      print('No vehicle details found.');
      return [];
    }

    final appData = Provider.of<AppData>(context, listen: false);
    final LatLng pickDestination = LatLng(
      appData.pickupAddress.latitude,
      appData.pickupAddress.longituge,
    );
    final LatLng userDestination = LatLng(
      appData.destinationAddress.latitude,
      appData.destinationAddress.longituge,
    );

    final List<Future<AvailableVehicles?>> vehicleFutures =
        vehiclesDetails.entries.map((entry) async {
      final uid = entry.key;
      final vehicleData = entry.value;

      final LatLng start =
          LatLng(vehicleData['startLat'], vehicleData['startLng']);
      final LatLng end = LatLng(vehicleData['endLat'], vehicleData['endLng']);
      final directionDetails = await getDirectionDetails(start, end);

      if (directionDetails == null) {
        print('Direction details not available for UID: $uid');
        return null;
      }

      final List<PointLatLng> decodedPoints =
          PolylinePoints().decodePolyline(directionDetails.encodedPoints);

      // Initialize min distance variables
      int startKm = 100, endKm = 100;
      LatLng startLatLng = LatLng(0.0, 0.0), endLatLng = LatLng(0.0, 0.0);

      for (final point in decodedPoints) {
        final LatLng positionOnWay = LatLng(point.latitude, point.longitude);

        // Calculate haversine distances
        final int haversineStart = haversine(positionOnWay, pickDestination);
        if (haversineStart < 5 && haversineStart < startKm) {
          startKm = haversineStart;
          startLatLng = positionOnWay;
        }

        final int haversineEnd = haversine(positionOnWay, userDestination);
        if (haversineEnd < 5 && haversineEnd < endKm) {
          endKm = haversineEnd;
          endLatLng = positionOnWay;
        }
      }

      if (startKm > 0 && endKm > 0) {
        final startPlaceName = await returnPlaceAddress(startLatLng);
        final endPlaceName = await returnPlaceAddress(endLatLng);

        return AvailableVehicles(
          startKm: startKm,
          endKm: endKm,
          uid: uid,
          startPlaceName: startPlaceName,
          endPlaceName: endPlaceName,
        );
      }
      return null;
    }).toList();

    // Process vehicle futures in parallel
    final vehicles = await Future.wait(vehicleFutures);
    return vehicles.whereType<AvailableVehicles>().toList();
  }

  static int haversine(LatLng start, LatLng end) {
    const double R = 6371000; // Earth's radius in meters
    double phi1 = start.latitude * pi / 180; // Start latitude in radians
    double phi2 = end.latitude * pi / 180; // End latitude in radians
    double deltaPhi = (end.latitude - start.latitude) *
        pi /
        180; // Latitude difference in radians
    double deltaLambda = (end.longitude - start.longitude) *
        pi /
        180; // Longitude difference in radians

    double a = pow(sin(deltaPhi / 2), 2) +
        cos(phi1) * cos(phi2) * pow(sin(deltaLambda / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distanceInMeters = R * c; // Distance in meters
    double distanceInKm = distanceInMeters / 1000; // Convert to kilometers

    return distanceInKm.round(); // Return rounded distance in kilometers
  }
}
