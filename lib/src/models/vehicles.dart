class Vehicle {
  String vehicleNo;
  String vehicleName;
  double vehiclePrice;
  String driverName;
  String routeDetails;
  String driverUid;
  String vehicleImage;
  String startPlaceName;
  String endPlaceName;
  int startKm;
  int endKm;

  Vehicle(
      {required this.vehicleNo,
      required this.vehicleName,
      required this.vehiclePrice,
      required this.driverName,
      required this.routeDetails,
      required this.driverUid,
      required this.vehicleImage,
      required this.startKm,
      required this.endKm,
      required this.startPlaceName,
      required this.endPlaceName});

  // Factory method to create a Vehicle object from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json, String uid, int startKm,
      int endKm, String startPlaceName, String endPlaceName) {
    return Vehicle(
        vehicleNo: json['vehicleNo'] as String,
        vehicleName: json['vehicleName'] as String,
        vehiclePrice: (json['vehiclePrice'] as num).toDouble(),
        driverName: json['driverName'] as String,
        routeDetails: json['routeDetails'] as String,
        driverUid: uid,
        vehicleImage: json['vehicleImage'] as String,
        endPlaceName: endPlaceName,
        startKm: startKm,
        endKm: endKm,
        startPlaceName: startPlaceName);
  }
}
