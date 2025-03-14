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
  String vehicleType;
  String seatCapacity;
  String driverExperience;
  String lang;
  String mainPoints;

  int startKm;
  int endKm;
  double rate;
  int count;

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
      required this.endPlaceName,
      required this.rate,
      required this.count,
      required this.driverExperience,
      required this.lang,
      required this.mainPoints,
      required this.vehicleType,
      required this.seatCapacity});

  // Factory method to create a Vehicle object from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json, String uid, int startKm,
      int endKm, String startPlaceName, String endPlaceName) {
    return Vehicle(
        vehicleNo: json['vehicleNo'] as String,
        vehicleName: json['vehicleName'] as String,
        vehiclePrice: double.tryParse(json['vehiclePrice'].toString()) ?? 0.0,
        driverName: json['fullname'] as String,
        routeDetails: json['routeDetails'] as String,
        driverUid: uid,
        vehicleImage: json['vehicleImage'] as String,
        endPlaceName: endPlaceName,
        startKm: startKm,
        endKm: endKm,
        startPlaceName: startPlaceName,
        count: json['ratings']['count'] ?? 0,
        rate: (json['ratings']['average']) * 1.0 ?? 5.0,
        seatCapacity: json['seatCapacity'],
        driverExperience: json['experience'],
        lang: json['lanuage'],
        vehicleType: json['vehicleType'],
        mainPoints: json['startPlaceName'] + " to " + json['endPlaceName']);
  }
}
