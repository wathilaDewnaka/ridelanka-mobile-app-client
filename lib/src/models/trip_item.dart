class TripItem {
  final String id;
  final String source;
  final String destination;
  final String status;
  final double price;
  final String vehicleType;
  final String date;
  final String driverName;
  final String vehicleNo;
  final String trpId;
  final String attTime;
  final String isComming;

  TripItem(
      {required this.id,
      required this.source,
      required this.destination,
      required this.status,
      required this.price,
      required this.vehicleType,
      required this.date,
      required this.driverName,
      required this.trpId,
      required this.vehicleNo,
      required this.attTime,
      required this.isComming});

  factory TripItem.fromJson(Map<dynamic, dynamic> json, String? trpId) {
    return TripItem(
        id: json['driverUid'] ?? '',
        source: json['start'] ?? '',
        destination: json['end'] ?? '',
        status: json['isActive'] ?? '',
        price: json['price'] is double
            ? json['price']
            : double.tryParse(json['price'].toString()) ??
                0.0, // Convert price to double
        vehicleType: json['vehicleName'] ?? '',
        date: json['subscriptionDate'] ?? '',
        driverName: json['driverName'] ?? '',
        vehicleNo: json['vehicleNo'] ?? '',
        trpId: trpId ?? "",
        attTime: json['isActive'] == 'Active' ? json['attendance']['timestamp'] : '',
        isComming: json['isActive'] == 'Active' ? json['attendance']['isComming'] : '');
  }
}
