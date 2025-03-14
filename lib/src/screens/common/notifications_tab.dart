import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/methods/push_notification_service.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:client/src/widgets/progress_dialog.dart';
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
  bool loading = true;

  Future<void> getNotifications() async {
    bool isPassenger = await HelperMethods.checkIsPassenger(firebaseUser!.uid);

    DatabaseReference notifications = isPassenger
        ? FirebaseDatabase.instance
            .ref()
            .child('users/${firebaseUser!.uid}/notifications')
        : FirebaseDatabase.instance
            .ref()
            .child('drivers/${firebaseUser!.uid}/notifications');

    DataSnapshot mainNotificationsSnapshot =
        await notifications.limitToLast(10).get();
    if (mainNotificationsSnapshot.exists) {
      print("Exist");
      List<NotificationItem> newNotifications = [];
      mainNotificationsSnapshot.children.forEach((child) {
        Map<dynamic, dynamic> notificationData =
            child.value as Map<dynamic, dynamic>;

        NotificationItem notificationItem =
            NotificationItem.fromJson(notificationData, child.key);
        newNotifications.add(notificationItem);
        markAsRead(child.key);
      });

      if (mounted) {
        setState(() {
          notificationAll = newNotifications.reversed
              .toList(); // Update the state with the new notifications
        });
      }
    } else {
      print("No notifications found in the main path.");
    }

    setState(() {
      loading = false;
    });
  }

  void renewBooking(String? notificationId, String? userIds) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );

    if (userIds == null || !userIds.contains(" ")) {
      Navigator.pop(context);
      return;
    }

    String userId = userIds.split(" ")[0];
    String notiId = userIds.split(" ")[1];

    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/notifications/$notificationId');

    DatabaseReference userReference =
        FirebaseDatabase.instance.ref().child('users/$userId/bookings/$notiId');

    DatabaseReference userNotificationReference =
        FirebaseDatabase.instance.ref().child('users/$userId/notifications');

    Map<String, String> userNotifications = {
      "title": "Booking Renew Accepted",
      "description": "Subscription renewed for 30 days",
      "icon": "tick",
      "date": DateTime.now().microsecondsSinceEpoch.toString(),
      "isRead": "false",
      "isActive": ""
    };

    try {
      DatabaseReference fcm =
          FirebaseDatabase.instance.ref().child("drivers/$userId/token");
      DataSnapshot snapshot = await fcm.get();
      String token = snapshot.value as String;
      PushNotificationService.sendNotificationsToUsers(
          token, "Booking Renewed", "Driver renewed your booking");
    } catch (e) {
      print(e);
    }

    await userNotificationReference.push().set(userNotifications);
    await databaseReference.update({'isRead': "true", 'isActive': ''});

    String differenceInMicroseconds = "0";

    DataSnapshot snapshot = await userReference.get();
    String? microseconds =
        snapshot.child('subscriptionDate').value as String? ?? "";

    DateTime subscriptionDate =
        DateTime.fromMicrosecondsSinceEpoch(int.tryParse(microseconds) ?? 0)
            .add(Duration(days: 30));

    differenceInMicroseconds =
        subscriptionDate.microsecondsSinceEpoch.toString();

    await userReference.update({
      'isActive': "Active",
      "subscriptionDate": differenceInMicroseconds,
    });

    await getNotifications();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
      message: "Booking approved successfully!",
      title: "Success",
      type: MessageType.success,
    ));
  }

  void rejectRenewal(String notificationId) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );

    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/notifications/$notificationId');
    await databaseReference.update({'isRead': "true", 'isActive': ''});
    await getNotifications();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
      message: "Booking rejected successfully !",
      title: "Success",
      type: MessageType.success,
    ));
  }

  void updateBookings(String? notificationId, String? userId) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );

    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/notifications/$notificationId');

    DatabaseReference driverBookingReference = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/bookings');

    DatabaseReference userReference = FirebaseDatabase.instance
        .ref()
        .child('users/${userId}/bookings/$notificationId');
    DatabaseEvent event = await userReference.once();

    if (event.snapshot.exists) {
      Map<dynamic, dynamic>? bookingData =
          event.snapshot.value as Map<dynamic, dynamic>?;

      DatabaseReference userNotificationReference = FirebaseDatabase.instance
          .ref()
          .child('users/${userId}/notifications');

      Map<String, String> userNotifications = {
        "title": "Booking Request Accepted",
        "description": "Booking request accepted by the driver",
        "icon": "tick",
        "date": DateTime.now().microsecondsSinceEpoch.toString(),
        "isRead": "false",
        "isActive": ""
      };

      try {
        DatabaseReference fcm =
            FirebaseDatabase.instance.ref().child("users/$userId/token");
        DataSnapshot snapshot = await fcm.get();
        String token = snapshot.value as String;
        PushNotificationService.sendNotificationsToUsers(
            token, "Booking Accepted", "Your booking is accepted");
      } catch (e) {
        print(e);
      }

      Map<dynamic, dynamic> bookingReference = {
        "uId": userId ?? "",
        "marked": "false",
        "location": {
          "startLat": bookingData?['location']['startLat'],
          "startLng": bookingData?['location']['startLng'],
          "endLat": bookingData?['location']['endLat'],
          "endLng": bookingData?['location']['endLng']
        }
      };

      await driverBookingReference.push().set(bookingReference);
      await userNotificationReference.push().set(userNotifications);
      await databaseReference.update({'isRead': "true", 'isActive': ''});
      await userReference.update({
        'isActive': "Active",
        "subscriptionDate": DateTime.now()
            .add(Duration(days: 30))
            .microsecondsSinceEpoch
            .toString(),
        "attendance": {
          "isComming": "not_marked",
          "timestamp": DateTime.now()
              .subtract(Duration(days: 1))
              .microsecondsSinceEpoch
              .toString()
        }
      });
    }
    await getNotifications();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
      message: "Booking approved successfully !",
      title: "Success",
      type: MessageType.success,
    ));
  }

  void rejectBookings(String? notificationId, String? userId) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('drivers/${firebaseUser!.uid}/notifications/$notificationId');

    DatabaseReference userReference = FirebaseDatabase.instance
        .ref()
        .child('users/$userId/bookings/$notificationId');

    DatabaseReference userNotificationReference =
        FirebaseDatabase.instance.ref().child('users/$userId/notifications');

    Map<String, String> userNotifications = {
      "title": "Booking Request Rejected",
      "description": "Booking request rejected by the driver",
      "icon": "cross",
      "date": DateTime.now().microsecondsSinceEpoch.toString(),
      "isRead": "false",
      "isActive": ""
    };

    await userNotificationReference.push().set(userNotifications);

    try {
      DatabaseReference fcm =
          FirebaseDatabase.instance.ref().child("users/$userId/token");
      DataSnapshot snapshot = await fcm.get();
      String token = snapshot.value as String;
      PushNotificationService.sendNotificationsToUsers(
          token, "Booking Rejected", "Driver rejected your recent booking ");
    } catch (e) {
      print(e);
    }

    await databaseReference.update({
      'isRead': "true",
      'isActive': '',
    });

    await userReference.remove();
    await getNotifications();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
      message: "Booking rejected successfully !",
      title: "Success",
      type: MessageType.success,
    ));
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Please wait...'),
      );

      // Initialize async tasks
      getNotifications().then((_) {
        // After tasks are complete, dismiss the dialog
        print("object");
        Navigator.pop(context);
      }).catchError((error) {
        Navigator.pop(context);
      });
    });
  }

  IconData getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'new':
        return Icons.label;
      case 'cross':
        return Icons.crop_square_sharp;
      case 'tick':
        return Icons.approval;
      case 'payment':
        return Icons.credit_card;
      case 'call':
        return Icons.call;
      default:
        return Icons.help;
    }
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
                onPressed: () async {
                  bool isPass =
                      await HelperMethods.checkIsPassenger(firebaseUser!.uid);
                  if (isPass) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RiderNavigationMenu.id,
                      (route) => false,
                    );
                  } else {
                    Navigator.pop(context);
                  }
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
              child: notificationAll.isEmpty && !loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        child: Text(
                          "No notifications avaiable",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 14),
                      itemCount: notificationAll.length,
                      itemBuilder: (context, index) {
                        final notification = notificationAll[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: notification.isRead
                                ? Colors.white
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: notification.isRead
                                  ? Colors.grey.withOpacity(0.2)
                                  : NotificationTab.mainBlue.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    NotificationTab.mainBlue.withOpacity(0.1),
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
                                        ? NotificationTab.mainBlue
                                            .withOpacity(0.1)
                                        : NotificationTab.mainBlue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    getIconFromString(notification.icon),
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
                              if (notification.isActive.isNotEmpty &&
                                  (notification.title == "Booking Request" ||
                                      notification.title ==
                                          "Booking Renewal !"))
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: NotificationTab.mainBlue
                                        .withOpacity(0.03),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          notification.title ==
                                                  "Booking Renewal !"
                                              ? rejectRenewal(notification.id)
                                              : rejectBookings(notification.id,
                                                  notification.isActive);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              NotificationTab.mainBlue,
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
                                        onPressed: () {
                                          notification.title ==
                                                  "Booking Renewal !"
                                              ? renewBooking(notification.id,
                                                  notification.isActive)
                                              : updateBookings(notification.id,
                                                  notification.isActive);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              NotificationTab.mainBlue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Approve',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
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
    final time =
        DateTime.fromMicrosecondsSinceEpoch(int.parse(microsecondsSinceEpoch));

    final difference = now.difference(time);

    // Calculate the difference in microseconds
    final microseconds =
        difference.inMicroseconds.toDouble(); // Explicitly convert to double

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
