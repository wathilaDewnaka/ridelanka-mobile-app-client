import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/screens/auth/on_board_screen.dart';
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
  List<NotificationItem> notificationAll = [];

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
      List<NotificationItem> newNotifications = [];
      mainNotificationsSnapshot.children.forEach((child) {
        Map<dynamic, dynamic> notificationData =
            child.value as Map<dynamic, dynamic>;

        // Convert the notification data to NotificationItem
        NotificationItem notificationItem =
            NotificationItem.fromJson(notificationData);
        newNotifications.add(notificationItem);

        markAsRead(child.key);
      });

      if (mounted) {
        setState(() {
          notificationAll =
              newNotifications; // Update the state with the new notifications
        });
      }
    } else {
      print("No notifications found in the main path.");
    }
  }

  void updateBookings(String? notificationId, String? userId) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/notifications/$notificationId');

    await databaseReference.update({
      'isRead': "true",
    });

    getNotifications();
  }

  void markAsRead(String? notificationId) async {
    bool isPassenger = await HelperMethods.checkIsPassenger(firebaseUser!.uid);

    DatabaseReference notifications = isPassenger
        ? FirebaseDatabase.instance
            .ref()
            .child('users/${firebaseUser!.uid}/notifications/$notificationId')
        : FirebaseDatabase.instance.ref().child(
            'drivers/${firebaseUser!.uid}/notifications/$notificationId');
    await notifications.update({
      'isRead': "true",
    });
  }

  @override
  void initState() {
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
                    '${notificationAll.length} Notifications',
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
                itemCount: notificationAll.length,
                itemBuilder: (context, index) {
                  final notification = notificationAll[index];
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
                              Icons.new_label,
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
                                _formatTime(notification.date),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: NotificationTab.mainBlue.withOpacity(0.03),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: NotificationTab.mainBlue,
                                ),
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: NotificationTab.mainBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Approve',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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

  String _formatTime(String microsecondsSinceEpoch) {
  final now = DateTime.now();
  final time = DateTime.fromMicrosecondsSinceEpoch(int.parse(microsecondsSinceEpoch));

  final difference = now.difference(time);

  // Calculate the difference in microseconds
  final microseconds = difference.inMicroseconds.toDouble(); // Explicitly convert to double

  final oneMillion = 1000000.0; 

  if (microseconds < 60 * oneMillion) {
    // Less than 1 minute
    return '${(microseconds / oneMillion).toStringAsFixed(0)} seconds ago'; // Showing microseconds in seconds
  } else if (microseconds < 60 * 60 * oneMillion) {
    // Less than 1 hour
    return '${(microseconds / oneMillion / 60).toStringAsFixed(0)} minutes ago'; // Showing minutes with decimal
  } else if (microseconds < 24 * 60 * 60 * oneMillion) {
    // Less than 1 day
    return '${(microseconds / oneMillion / 60 / 60).toStringAsFixed(0)} hours ago'; // Showing hours with decimal
  } else {
    // More than 1 day
    return '${time.day}/${time.month}/${time.year}';
  }
}
}
