class TripItem {
  final String id;
  final String source;
  final String destination;
  final TripStatus status;
  final double price;
  final String vehicleType;
  final String expDate;
  final String driverName;
  final String driverId;

  TripItem(
      {required this.id,
      required this.source,
      required this.destination,
      required this.status,
      required this.price,
      required this.vehicleType,
      required this.expDate,
      required this.driverName,
      required this.driverId
      });
}

enum TripStatus { active, inactive }
