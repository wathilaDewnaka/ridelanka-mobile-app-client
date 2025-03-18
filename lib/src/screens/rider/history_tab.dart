import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/methods/push_notification_service.dart';
import 'package:client/src/models/trip_item.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:client/src/screens/rider/track_vehicle.dart';
import 'package:client/src/screens/common/chat_screen.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  static const Color mainBlue = Color(0xFF0051ED);
  String selectedFilter = 'All';
  bool loading = true;

  List<TripItem> trips = [];

  Future<void> getTrips() async {
    DatabaseReference notifications = FirebaseDatabase.instance
        .ref()
        .child('users/${firebaseUser!.uid}/bookings');

    DataSnapshot mainNotificationsSnapshot = await notifications.get();
    if (mainNotificationsSnapshot.exists) {
      List<TripItem> newNotifications = [];
      for (var child in mainNotificationsSnapshot.children) {
        if (child.value is Map<dynamic, dynamic>) {
          try {
            Map<dynamic, dynamic> notificationData =
                child.value as Map<dynamic, dynamic>;
            String? driverUid = notificationData['driverUid'] as String?;

            DatabaseReference driverRef =
                FirebaseDatabase.instance.ref().child('drivers/$driverUid');
            DataSnapshot snapshot = await driverRef.get();

            Map<dynamic, dynamic> driverData =
                snapshot.value as Map<dynamic, dynamic>;

            double vehiclePrice = driverData['vehiclePrice'] is double
                ? driverData['vehiclePrice']
                : double.tryParse(driverData['vehiclePrice'].toString()) ?? 0.0;

            newNotifications.add(TripItem.fromJson(
                notificationData,
                child.key,
                vehiclePrice,
                driverData['fullname'] ?? "",
                driverData['vehicleName'] ?? "",
                driverData['vehicleNo'] ?? "",
                driverData['phone'] ?? ""));
          } catch (e) {
            print(e);
          }
        }
      }

      if (mounted) {
        setState(() {
          loading = false;
          trips = newNotifications.reversed.toList();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void updateExpiredTrips(
      String tripId, String subscriptionDate, String status) async {
    if (tripId.isNotEmpty &&
        daysLeft(subscriptionDate) > -2 &&
        daysLeft(subscriptionDate) < 1 &&
        status == "Active") {
      DatabaseReference book = FirebaseDatabase.instance
          .ref()
          .child('users/${firebaseUser!.uid}/bookings/$tripId');
      await book.update({'isActive': "Inactive"});
      getTrips();
    }
  }

  void renewSubscription(String tripId) async {
    if (tripId.isEmpty) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );

    DatabaseReference book = FirebaseDatabase.instance
        .ref()
        .child('users/${firebaseUser!.uid}/bookings/$tripId');

    DatabaseEvent event = await book.once();
    DataSnapshot dataSnapshot = event.snapshot;

    Map<Object?, Object?> bookingData =
        dataSnapshot.value as Map<Object?, Object?>;

    String? driverUid = bookingData['driverUid'] as String?;

    DatabaseReference noti = FirebaseDatabase.instance
        .ref()
        .child('drivers/$driverUid/notifications');
    String? name = await HelperMethods.getPassengerFullName(firebaseUser!.uid);

    Map<String, String> driverNotifications = {
      "title": "Booking Renewal !",
      "description":
          "User at ${dataSnapshot.child('start').value} who is $name is wants to renew subscription",
      "icon": "user",
      "date": DateTime.now().microsecondsSinceEpoch.toString(),
      "isRead": "false",
      "isActive": firebaseUser!.uid + " " + tripId
    };

    noti.push().set(driverNotifications);

    try {
      DatabaseReference fcm =
          FirebaseDatabase.instance.ref().child("drivers/$driverUid/token");
      DataSnapshot snapshot = await fcm.get();
      String token = snapshot.value as String;
      PushNotificationService.sendNotificationsToUsers(
          token, "User Renew Request", "User has been added a renew request");
    } catch (e) {
      print(e);
    }
    await getTrips();

    Navigator.pop(context);
  }

  void markAttendance(String tripId) async {
    if (tripId.isEmpty) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );

    DatabaseReference book = FirebaseDatabase.instance
        .ref()
        .child('users/${firebaseUser!.uid}/bookings/$tripId');

    DatabaseEvent event = await book.once();
    DataSnapshot dataSnapshot = event.snapshot;

    // Cast value to Map<Object?, Object?> first
    Map<Object?, Object?> bookingData =
        dataSnapshot.value as Map<Object?, Object?>;

    // Now, safely cast to Map<String, dynamic> and access the driverUid
    String? driverUid = bookingData['driverUid'] as String?;

    await book.update({
      'attendance': {
        'isComming': 'not_comming',
        'timestamp': DateTime.now().microsecondsSinceEpoch.toString(),
      }
    });

    String? name = await HelperMethods.getPassengerFullName(firebaseUser!.uid);

    try {
      DatabaseReference fcm =
          FirebaseDatabase.instance.ref().child("drivers/$driverUid/token");
      DataSnapshot snapshot = await fcm.get();
      String token = snapshot.value as String;
      PushNotificationService.sendNotificationsToUsers(
          token, "User Absenting Tommarow", "User is absenting check details");
    } catch (e) {
      print(e);
    }

    Map<String, String> driverNotifications = {
      "title": "Absent Notification !",
      "description":
          "User at ${dataSnapshot.child('start').value} who is $name is not comming today",
      "icon": "user",
      "date": DateTime.now().microsecondsSinceEpoch.toString(),
      "isRead": "false",
      "isActive": ""
    };

    DatabaseReference driverNotification = FirebaseDatabase.instance
        .ref()
        .child('drivers/$driverUid/notifications');

    await driverNotification.push().set(driverNotifications);
    await getTrips();

    Navigator.pop(context);
  }

  List<TripItem> getFilteredTrips() {
    switch (selectedFilter) {
      case 'Active':
        return trips.where((trip) => trip.status == "Active").toList();
      case 'Inactive':
        return trips.where((trip) => trip.status == "Inactive").toList();
      case 'Pending':
        return trips.where((trip) => trip.status == "Pending").toList();
      default:
        return trips;
    }
  }

  int daysLeft(String subscriptionDate) {
    // Convert the subscription date string to an integer
    try {
      int subscriptionDateInt = int.parse(subscriptionDate);

      // If the timestamp is in microseconds, convert it to milliseconds
      if (subscriptionDateInt.toString().length == 16) {
        subscriptionDateInt = (subscriptionDateInt / 1000).round();
      }

      // Convert the integer to a DateTime object
      DateTime subscriptionEndDate =
          DateTime.fromMillisecondsSinceEpoch(subscriptionDateInt);
      DateTime currentDate = DateTime.now();

      // Calculate the difference in days
      int remainingDays = subscriptionEndDate.difference(currentDate).inDays;

      // Return the remaining days if positive, otherwise return -1
      return remainingDays > 0 ? remainingDays : -1;
    } catch (e) {
      return -2;
    }
  }

  int daysPassedCalc(String timeStamp) {
    DateTime lastMarkedDate =
        DateTime.fromMicrosecondsSinceEpoch(int.parse(timeStamp));
    DateTime today = DateTime.now();

    DateTime lastDateOnly =
        DateTime(lastMarkedDate.year, lastMarkedDate.month, lastMarkedDate.day);
    DateTime todayOnly = DateTime(today.year, today.month, today.day);

    return todayOnly.difference(lastDateOnly).inDays;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Please wait...'),
      );

      // Initialize async tasks
      getTrips().then((_) {
        // After tasks are complete, dismiss the dialog
        print("object");
        Navigator.pop(context);
      }).catchError((error) {
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBlue,
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RiderNavigationMenu.id,
                    (route) => false,
                  );
                },
              ),
              elevation: 0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 17.0),
              child: Text(
                "Trip History",
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Active', 'Inactive', 'Pending']
                          .map((filter) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: FilterChip(
                                  label: Text(filter),
                                  selected: selectedFilter == filter,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedFilter = filter;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: mainBlue.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: selectedFilter == filter
                                        ? mainBlue
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                  side: BorderSide(
                                    color: selectedFilter == filter
                                        ? mainBlue
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: getFilteredTrips().isEmpty && !loading
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        child: Text(
                          "No ${selectedFilter == "All" ? "" : selectedFilter} trips available",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      itemCount: getFilteredTrips().length,
                      itemBuilder: (context, index) {
                        TripItem trip = getFilteredTrips()[index];
                        updateExpiredTrips(trip.trpId, trip.date, trip.status);
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: trip.status == "Active"
                                  ? mainBlue.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: mainBlue.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: trip.status == "Active"
                                                    ? mainBlue.withOpacity(0.1)
                                                    : trip.status == "Pending"
                                                        ? Colors.yellow[50]
                                                        : Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                trip.status == "Active"
                                                    ? 'Active'
                                                    : trip.status == "Pending"
                                                        ? "Pending"
                                                        : 'Inactive',
                                                style: TextStyle(
                                                  color: trip.status == "Active"
                                                      ? mainBlue
                                                      : trip.status == "Pending"
                                                          ? Colors.yellow[900]
                                                          : Colors.grey[600],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.directions_car,
                                                color: Colors.grey[600],
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              trip.vehicleNo,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'LKR.${trip.price.toStringAsFixed(2)}/Month',
                                          style: const TextStyle(
                                            color: mainBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: mainBlue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: mainBlue,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                trip.source,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                height: 1,
                                                color: Colors.grey[300],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                trip.destination,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.drive_eta),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                trip.vehicleType,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          if (trip.status == "Active")
                                            Text(
                                              daysLeft(trip.date) > 0
                                                  ? "Expires in ${daysLeft(trip.date)} days"
                                                  : "Expired",
                                              style: TextStyle(
                                                color: daysLeft(trip.date) < 5
                                                    ? Colors.red[600]
                                                    : Colors.grey[500],
                                                fontWeight:
                                                    daysLeft(trip.date) < 5
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if (trip.status == "Active")
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: mainBlue.withOpacity(0.03),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                      recieverName:
                                                          trip.driverName,
                                                      recieverUid:
                                                          "drivers " + trip.id,
                                                      recieverTel:
                                                          trip.driverPhone,
                                                      isMobile: true,
                                                      senderId:
                                                          "users ${firebaseUser!.uid}",
                                                    )),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.blue,
                                              child: Text(
                                                trip.driverName.split(" ")[1]
                                                    [0],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              trip.driverName.contains(" ")
                                                  ? trip.driverName
                                                          .split(" ")[0] +
                                                      " " +
                                                      trip.driverName
                                                          .split(" ")[1]
                                                  : trip.driverName[0],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TrackVehicle()));
                                            },
                                            icon: const Icon(Icons.visibility,
                                                size: 18),
                                            label: const Text('Track Trip '),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: mainBlue,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          if (daysLeft(trip.date) > 0 &&
                                                  daysPassedCalc(trip.attTime) >
                                                      0 ||
                                              trip.isComming == 'not_marked')
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                markAttendance(trip.trpId);
                                              },
                                              icon: const Icon(
                                                Icons.person,
                                                size: 18,
                                              ),
                                              label: const Text('Absenting'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 80, 153, 232),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          if (daysLeft(trip.date) < 10)
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                renewSubscription(trip.trpId);
                                              },
                                              icon: const Icon(
                                                Icons.plus_one_outlined,
                                                size: 18,
                                              ),
                                              label: const Text('Renew Trip'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red[600],
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            )
                                        ],
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
}
