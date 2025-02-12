class Vehicle {
  String vehicleNo;
  double vehiclePrice;
  String driverName;
  String routeDetails;
  String driverUid;

  Vehicle({
    required this.vehicleNo,
    required this.vehiclePrice,
    required this.driverName,
    required this.routeDetails,
    required this.driverUid,
  });

  // Factory method to create a Vehicle object from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleNo: json['vehicleNo'] as String,
      vehiclePrice: (json['vehiclePrice'] as num).toDouble(),
      driverName: json['driverName'] as String,
      routeDetails: json['routeDetails'] as String,
      driverUid: json['driverUid'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleNo': vehicleNo,
      'vehiclePrice': vehiclePrice,
      'driverName': driverName,
      'routeDetails': routeDetails,
      'driverUid': driverUid,
    };
  }
}
