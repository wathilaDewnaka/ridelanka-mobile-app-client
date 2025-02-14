class TripItem {
  final String id;
  final String source;
  final String destination;
  final String status;
  final double price;
  final String vehicleType;
  final String date;
  final String driverName;
  final String driverId;

  TripItem(
      {required this.id,
      required this.source,
      required this.destination,
      required this.status,
      required this.price,
      required this.vehicleType,
      required this.date,
      required this.driverName,
      required this.driverId
      });
}
