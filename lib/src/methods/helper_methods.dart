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
        'https://maps.googleapis.com/maps/api/directions/json?destination=${endPosition.latitude.toString()},${endPosition.longitude.toString()}&origin=${startPosition.latitude.toString()},${startPosition.longitude.toString()}&key=$mapKey';
    
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
      return event.snapshot
          .exists; 
    } catch (e) {
      return false; 
    }
  }
  
}

