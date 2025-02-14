import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String description;
  final String date;
  final bool isRead;
  final String icon;
  final String? isActive;

  NotificationItem(
      {required this.title,
      required this.description,
      required this.date,
      required this.isRead,
      required this.icon,
      this.isActive});

  // Factory method to create a Notification object from JSON
  factory NotificationItem.fromJson(Map<dynamic, dynamic> json) {
    return NotificationItem(
      title: json['title'] ?? '', // Default to empty string if missing
      description:
          json['description'] ?? '', // Default to empty string if missing
      date: json['date'],
      isRead: json['isRead'] == "true" ||
          json['isRead'] == true, // Convert String or bool to bool
      icon: json['icon'] ?? '', // Default to empty string if missing
    );
  }
}
