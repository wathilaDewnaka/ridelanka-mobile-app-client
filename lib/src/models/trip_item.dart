class TripItem {
  final String id;
  final String source;
  final String destination;
  final TripStatus status;
  final double price;
  final String vehicleType;
  final String expDate;

  TripItem(
      {required this.id,
      required this.source,
      required this.destination,
      required this.status,
      required this.price,
      required this.vehicleType,
      required this.expDate});
}


enum TripStatus { active, inactive }
