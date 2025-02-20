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
        title: const Text('Attendance'),
      ),
      body: Column(
        children: [
          Row(
            children: const [
              Text('Student Name'),
              Spacer(),
              Text('Present / Absent'),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Text(_students[index]['name']),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _toggleAttendance(index, 'P'),
                      child: const Text('P'),
                    ),
                    ElevatedButton(
                      onPressed: () => _toggleAttendance(index, 'A'),
                      child: const Text('A'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
