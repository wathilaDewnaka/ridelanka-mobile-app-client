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
    placeName: 'Where are you going ?',
    latitude: 0.0,
    longituge: 0.0,
    placeId: '',
    placeFormattedAddress: '',
  );

  Address driverStartAddress = Address(
    placeName: 'Start Address',
    latitude: 0.0,
    longituge: 0.0,
    placeId: '',
    placeFormattedAddress: '',
  );

  Address driverEndAddress = Address(
    placeName: 'Driver End Address',
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

  void updateStartAddress(Address start) {
    driverStartAddress = start;
    notifyListeners();
  }

  void updateEndAddress(Address end) {
    driverEndAddress = end;
    notifyListeners();
  }
}
