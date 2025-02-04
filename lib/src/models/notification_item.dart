import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String description;
  final DateTime time;
  final bool isRead;
  final IconData icon;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
    required this.icon
  });
}