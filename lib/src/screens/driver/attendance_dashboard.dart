import 'package:flutter/material.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AttendancePage(),
    );
  }
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<Map<String, dynamic>> _students = [
    {'name': 'Blake Johnson', 'rollNo': 'Nalanda College', 'status': 'A'},
    {'name': 'Denise Scott', 'rollNo': 'Nalanda College', 'status': 'A'},
    {'name': 'Aaron Brown', 'rollNo': 'Nalanda College', 'status': 'A'},
    {'name': 'Oliver Wallace', 'rollNo': 'Royal College', 'status': 'A'},
    {'name': 'Angela Spader', 'rollNo': 'Devi Balika College', 'status': 'A'},
    {'name': 'David Peters', 'rollNo': 'Mahanama College', 'status': 'A'},
    {'name': 'Jim Rogers', 'rollNo': 'Ananada College', 'status': 'A'},
    {'name': 'Megan Long', 'rollNo': 'Isipathana College', 'status': 'A'},
  ];

  void _toggleAttendance(int index, String status) {
    setState(() {
      _students[index]['status'] = status;
    });
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
                              _students[index]['name'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _students[index]['rollNo'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _students[index]['status'] == 'P'
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
                              backgroundColor: _students[index]['status'] == 'A'
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

class AttendanceMark {
  final String id;
  final String name;
  final String timestamp;
  final String marked;
  final String userId;

  AttendanceMark(
      {required this.id,
      required this.name,
      required this.timestamp,
      required this.marked,
      required this.userId});

  factory AttendanceMark.fromJson(
      Map<dynamic, dynamic> json, String? trpId, String name) {
    return AttendanceMark(
      id: trpId ?? "",
      userId: json['userId'],
      name: name,
      timestamp: json['timestamp'],
      marked: json['marked'],
    );
  }
}
