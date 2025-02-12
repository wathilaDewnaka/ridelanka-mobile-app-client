class Vehicle {
  String vehicleNo;
  double vehiclePrice;
  String driverName;
  String routeDetails;
  String driverUid;
  String vehicleImage;

  Vehicle({
    required this.vehicleNo,
    required this.vehiclePrice,
    required this.driverName,
    required this.routeDetails,
    required this.driverUid,
    required this.vehicleImage
  });

  // Factory method to create a Vehicle object from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json, String uid) {
    return Vehicle(
      vehicleNo: json['vehicleNo'] as String,
      vehiclePrice: (json['vehiclePrice'] as num).toDouble(),
      driverName: json['driverName'] as String,
      routeDetails: json['routeDetails'] as String,
      driverUid: uid,
      vehicleImage: json['vehicleImage'] as String
    );
  }
}
