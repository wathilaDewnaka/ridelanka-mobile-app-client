import 'package:client/src/screens/rider/notifications_tab.dart';
import 'package:flutter/material.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  static const String id = "driver";

  @override
  Widget build(BuildContext context) {
    return NotificationTab();
  }
}
