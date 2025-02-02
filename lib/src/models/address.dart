class Address {
  String placeName;
  double latitude;
  double longituge;
  String placeId;
  String placeFormattedAddress;

  Address({
    required this.placeId,
    required this.latitude,
    required this.longituge,
    required this.placeName,
    required this.placeFormattedAddress,
  });
}
