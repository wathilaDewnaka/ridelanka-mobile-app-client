import 'package:flutter/material.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  static const String id = "driver";

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Hello Driver"),
    );
  }
}