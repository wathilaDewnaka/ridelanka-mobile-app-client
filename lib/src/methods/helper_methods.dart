import 'dart:math';

import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/globle_variable.dart';
import 'package:client/src/methods/request_helper.dart';
import 'package:client/src/models/address.dart';
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
    print('this is res :');
    print(response);
    print(url);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
      print('this is res :' + placeAddress);
      Address pickupAddress = new Address(
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
        Map<String, dynamic> driversData =
            Map<String, dynamic>.from(data as Map);
        Map<String, dynamic> filteredDetails = {};

        driversData.forEach((uid, driverData) {
          if (!(isStudent) && driverData['type'] == 'staff' ||
              isStudent && driverData['type'] == 'student') {
            if (driverData['location'] != null) {
              filteredDetails[uid] = {
                'startLat': driverData['location']['startLat'],
                'startLng': driverData['location']['startLng'],
                'endLat': driverData['location']['endLat'],
                'endLng': driverData['location']['endLng']
              };
            }
          }
        });

        return filteredDetails; // Returning the filtered details
      } else {
        print('No data available for any drivers.');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  static Future<List<String>> findNearestVehicles(
      BuildContext context, bool isStudent) async {
    // Fetch vehicle details
    Map<String, dynamic>? vehiclesDetails =
        await fetchVehicleDetails(isStudent);
    List<String> stringList = [];

    if (vehiclesDetails != null) {
      for (var entry in vehiclesDetails.entries) {
        var uid = entry.key;
        var vehicleData = entry.value;

        LatLng start = LatLng(vehicleData['startLat'], vehicleData['startLng']);
        LatLng end = LatLng(vehicleData['endLat'], vehicleData['endLng']);

        var directionDetails = await getDirectionDetails(start, end);

        if (directionDetails != null) {
          PolylinePoints polylinePoints = PolylinePoints();

          List<PointLatLng> decodedPoints =
              polylinePoints.decodePolyline(directionDetails.encodedPoints);

          bool isStartNearby = false;
          bool isEndNearby = false;

          LatLng pickDestination = LatLng(
            Provider.of<AppData>(context, listen: false).pickupAddress.latitude,
            Provider.of<AppData>(context, listen: false)
                .pickupAddress
                .longituge,
          );

          LatLng userDestination = LatLng(
            Provider.of<AppData>(context, listen: false)
                .destinationAddress
                .latitude,
            Provider.of<AppData>(context, listen: false)
                .destinationAddress
                .longituge,
          );

          for (PointLatLng point in decodedPoints) {
            LatLng positionOnWay = LatLng(point.latitude, point.longitude);

            if (haversine(positionOnWay, userDestination) < 5) {
              isEndNearby = true;
            }

            if (haversine(positionOnWay, pickDestination) < 5) {
              isStartNearby = true;
            }
          }

          if (isStartNearby && isEndNearby) {
            stringList.add(uid);
          }
        } else {
          print('Direction details not available for UID: $uid');
        }
      }

      // Print the results
      print('Nearest Vehicles: $stringList');
    } else {
      print('No vehicle details found.');
    }

    return stringList;
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
