import 'package:flutter/material.dart';

enum MessageType { success, error, info }

SnackBar createMessageBar({
  String title = "Success",
  String message = "Success message description",
  MessageType type = MessageType.success,
}) {
  // Set the color and icon based on the message type
  Color backgroundColor;
  Icon icon;

  switch (type) {
    case MessageType.error:
      backgroundColor = Colors.red;
      icon = const Icon(Icons.error, color: Colors.white, size: 40);
      break;
    case MessageType.info:
      backgroundColor = Colors.blue;
      icon = const Icon(Icons.info, color: Colors.white, size: 40);
      break;
    default:
      backgroundColor = Colors.green;
      icon = const Icon(Icons.check_circle, color: Colors.white, size: 40);
  }

  return SnackBar(
    padding: const EdgeInsets.all(0),
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 90,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 3,
    duration: const Duration(seconds: 2),
  );
}
