import 'package:client/src/models/address.dart';
import 'package:flutter/material.dart';


class AppData extends ChangeNotifier {
  Address pickupAddress = Address(
    placeName: 'Pickup Location',
    latitude: 0.0,
    longituge: 0.0,
    placeId: '',
    placeFormattedAddress: '',
  );

  Address destinationAddress = Address(
    placeName: '',
    latitude: 0.0,
    longituge: 0.0,
    placeId: '',
    placeFormattedAddress: '',
  );

  void updatePickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination) {
    destinationAddress = destination;
    notifyListeners();
  }
}
