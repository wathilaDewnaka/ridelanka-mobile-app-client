class Ratings {
  String fullname;
  String timestamp;
  double count;
  String description;
  String id;

  // Constructor
  Ratings({
    required this.fullname,
    required this.timestamp,
    required this.count,
    required this.description,
    required this.id
  });

  // Factory method to create an instance from JSON
  factory Ratings.fromJson(Map<dynamic, dynamic> json, String uid, String fullname) {
    return Ratings(
      fullname: fullname,
      timestamp: json['timestamp'] ?? '',
      count: json['rate'] * 1.0 ?? 5.0,
      description: json['message'] ?? '',
      id: uid,
    );
  }
}
