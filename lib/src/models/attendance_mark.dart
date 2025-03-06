class AttendanceMark {
  final String id;
  final String name;
  final String marked;
  final String userId;

  AttendanceMark(
      {required this.id,
      required this.name,
      required this.marked,
      required this.userId});

  factory AttendanceMark.fromJson(
      Map<dynamic, dynamic> json, String? trpId, String name) {
    return AttendanceMark(
      id: trpId ?? "",
      userId: json['uId'],
      name: name,
      marked: json['marked'],
    );
  }
}
