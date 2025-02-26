import 'package:client/global_variable.dart';
import 'package:client/src/models/attendance_mark.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<AttendanceMark> _students = [];
  bool loading = true;

  Future<void> getAttendance() async {
    DatabaseReference attendance = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/bookings');

    try {
      DataSnapshot mainAttendanceSnap = await attendance.get();

      if (mainAttendanceSnap.exists && mainAttendanceSnap.value != null) {
        List<AttendanceMark> newNotifications = [];

        for (var child in mainAttendanceSnap.children) {
          if (child.value is Map<dynamic, dynamic>) {
            Map<dynamic, dynamic> notificationData =
                child.value as Map<dynamic, dynamic>;
            print("object333");
            print(child.value);

            String? uid = notificationData['uId'] as String?;

            DatabaseReference driverRef =
                FirebaseDatabase.instance.ref().child('users/$uid');
            DataSnapshot snapshot = await driverRef.get();

            Map<dynamic, dynamic> userData =
                snapshot.value as Map<dynamic, dynamic>;

            AttendanceMark notificationItem = AttendanceMark.fromJson(
                notificationData, child.key, userData["fullname"]);
            newNotifications.add(notificationItem);
          }
        }

        if (mounted) {
          setState(() {
            _students = newNotifications.toList();
          });
        }
      } else {
        print("No notifications found in the main path.");
      }
    } catch (e) {
      print("Error fetching attendance: $e");
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void _toggleAttendance(int index, String status) async {
    AttendanceMark attendanceMark = _students[index];
    DatabaseReference att = FirebaseDatabase.instance
        .ref()
        .child("drivers/${firebaseUser!.uid}/bookings/${attendanceMark.id}");

    DatabaseReference noti = FirebaseDatabase.instance
        .ref()
        .child("users/${attendanceMark.userId}/notifications");

    await att.update({"marked": status});

    Map<String, String> userNotifications = {
      "title": "User has been picked up",
      "description": "User has been picked up by the driver",
      "icon": "tick",
      "date": DateTime.now().microsecondsSinceEpoch.toString(),
      "isRead": "false",
      "isActive": ""
    };

    await noti.push().set(userNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Attendance',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Batch title

          // Table headers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Colors.grey.shade300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Student Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(), // Pushes the next text to the right
                Text(
                  'Present / Absent',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right, // Ensures text is right-aligned
                ),
              ],
            ),
          ),

          // Student list
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _students[index].name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _students[index].name,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _students[index].marked == 'P'
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            onPressed: () => _toggleAttendance(index, 'P'),
                            child: const Text('P',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 5),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _students[index].marked == 'A'
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            onPressed: () => _toggleAttendance(index, 'A'),
                            child: const Text('A',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
