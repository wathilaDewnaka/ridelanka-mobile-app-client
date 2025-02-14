import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:client/src/models/notification_item.dart';

class NotificationTab extends StatefulWidget {
  NotificationTab({super.key});

  static const Color mainBlue = Color(0xFF0051ED);

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  List<Notification> notificationAll = [];

  final List<NotificationItem> notifications = [
    NotificationItem(
        title: "New Feature Available",
        description:
            "Check out our latest update with exciting new features! Tap to explore what's new in the app.",
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        icon: Icons.auto_awesome),
    NotificationItem(
        title: "Payment Successful",
        description:
            "Your transaction of \$299.99 has been processed successfully. Tap to view transaction details.",
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        icon: Icons.payment),
  ];

  void getNotifications() async {
    bool isPassenger = await HelperMethods.checkIsPassenger(firebaseUser!.uid);

    DatabaseReference notifications = isPassenger
        ? FirebaseDatabase.instance
            .ref()
            .child('users/${firebaseUser!.uid}/notifications')
        : FirebaseDatabase.instance
            .ref()
            .child('drivers/${firebaseUser!.uid}/notifications');

    DataSnapshot mainNotificationsSnapshot = await notifications.get();
    if (mainNotificationsSnapshot.exists) {
      mainNotificationsSnapshot.children.forEach((child) {
        Map<dynamic, dynamic> notificationData =
            child.value as Map<dynamic, dynamic>;
        // notificationAll.add(notificationData);

        print("Notification Key: ${child.key}");
        print(notificationData);
      });
    } else {
      print("No notifications found in the main path.");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotificationTab.mainBlue,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF0051ED),
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 17.0),
              child: Text(
                "Notifications",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 16, left: 18, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${notifications.length} Notifications',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 14),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: notification.isRead
                            ? Colors.grey.withOpacity(0.2)
                            : NotificationTab.mainBlue.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: NotificationTab.mainBlue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: notification.isRead
                                  ? NotificationTab.mainBlue.withOpacity(0.1)
                                  : NotificationTab.mainBlue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              notification.icon,
                              color: notification.isRead
                                  ? NotificationTab.mainBlue
                                  : Colors.white,
                              size: 24,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (!notification.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: NotificationTab.mainBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                notification.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTime(notification.time),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
