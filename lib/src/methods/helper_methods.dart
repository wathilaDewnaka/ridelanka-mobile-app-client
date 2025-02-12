import 'dart:math';

import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/globle_variable.dart';
import 'package:client/src/methods/request_helper.dart';
import 'package:client/src/models/address.dart';
import 'package:client/src/models/direction_details.dart';
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
    DatabaseReference ref = FirebaseDatabase.instance.ref("passengers/$uid");

    try {
      DatabaseEvent event = await ref.once();
      return event.snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  
  static Future<void> fetchVehicleDetails() async {
    Map <String, dynamic>? vehicleDetailsList;
    try {
      final DatabaseEvent event = await FirebaseDatabase.instance.ref('drivers').once();
      final data = event.snapshot.value;

      if (data != null) {
        Map<String, dynamic> driversData = Map<String, dynamic>.from(data as Map);

        Map<String, dynamic> filteredDetails = {};

        driversData.forEach((uid, driverData) {
          if (driverData['location'] != null) {
            filteredDetails[uid] = {
              'startLat': driverData['location']['startLat'],
              'startLng': driverData['location']['startLng'],
              'endLat': driverData['location']['endLat'],
              'endLng': driverData['location']['endLng']
            };
          }
        });

        vehicleDetailsList = filteredDetails;
      
        print('Filtered Vehicle Details: $vehicleDetailsList');
      } else {
        print('No data available for any drivers.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  static int haversine(Position start, Position end) {
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
