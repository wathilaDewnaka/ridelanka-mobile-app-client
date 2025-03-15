class AttendanceMark {
  final String id;
  final String name;
  final String marked;
  final String userId;
  final String phone;

  AttendanceMark(
      {required this.id,
      required this.name,
      required this.marked,
      required this.userId,
      required this.phone});

  factory AttendanceMark.fromJson(
      Map<dynamic, dynamic> json, String? trpId, String name, String phone) {
    return AttendanceMark(
        id: trpId ?? "",
        userId: json['uId'],
        name: name,
        marked: json['marked'],
        phone: phone);
  }
}
