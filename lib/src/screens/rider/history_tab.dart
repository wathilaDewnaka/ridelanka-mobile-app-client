import 'package:client/global_variable.dart';
import 'package:client/src/models/trip_item.dart';
import 'package:client/src/widgets/chat_screen.dart';
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

  List<TripItem> trips = [];

  Future<void> getTrips() async {
    DatabaseReference notifications = FirebaseDatabase.instance
        .ref()
        .child('users/${firebaseUser!.uid}/bookings');

    DataSnapshot mainNotificationsSnapshot = await notifications.get();
    if (mainNotificationsSnapshot.exists) {
      List<TripItem> newNotifications = [];
      mainNotificationsSnapshot.children.forEach((child) {
        if (child.value is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> notificationData =
              child.value as Map<dynamic, dynamic>;
          newNotifications.add(TripItem.fromJson(notificationData, child.key));
          print(notificationData);
        } else {
          // Handle invalid or unexpected data
          print('Invalid notification data: ${child.value}');
        }
      });

      if (mounted) {
        setState(() {
          trips = newNotifications.reversed.toList();
        });
      }
    } else {
      print("No notifications found in the main path.");
    }
  }

  void updateExpiredTrips(String tripId, String subscriptionDate) async {
    if (tripId.isNotEmpty &&
        daysLeft(subscriptionDate) > -2 &&
        daysLeft(subscriptionDate) < 1) {
      DatabaseReference book = FirebaseDatabase.instance
          .ref()
          .child('users/${firebaseUser!.uid}/bookings/$tripId');
      await book.update({'isActive': "Inactive"});
      getTrips();
    }
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
      DateTime subscriptionStartDate =
          DateTime.fromMillisecondsSinceEpoch(subscriptionDateInt);

      // Add 30 days to the subscription start date
      DateTime subscriptionEndDate =
          subscriptionStartDate.add(Duration(days: 30));

      // Get the current date and time
      DateTime currentDate = DateTime.now();

      // Calculate the difference in days
      int remainingDays = subscriptionEndDate.difference(currentDate).inDays;

      // Return the remaining days if positive, otherwise return -1
      return remainingDays > 0 ? remainingDays : -1;
    } catch (e) {
      return -2;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrips();
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
                  Navigator.pop(context);
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
              padding: const EdgeInsets.all(8),
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
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                itemCount: getFilteredTrips().length,
                itemBuilder: (context, index) {
                  TripItem trip = getFilteredTrips()[index];
                  updateExpiredTrips(trip.trpId, trip.date);
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
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
                                          color: Colors.grey[600], size: 16),
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
                                    'Rs.${trip.price.toStringAsFixed(2)}/Month',
                                    style: const TextStyle(
                                      color: mainBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                                      borderRadius: BorderRadius.circular(8),
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              trip.destination,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(Icons.drive_eta),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      trip.vehicleType,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: mainBlue.withOpacity(0.03),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                                recieverName: trip.driverName,
                                                recieverUid: trip.id,
                                                recieverTel: "",
                                                isMobile: true,
                                              )),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          trip.driverName,
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
                                      ? trip.driverName.split(" ")[0] + " " + trip.driverName.split(" ")[1]
                                      : trip.driverName[0],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.visibility,
                                          size: 18),
                                      label: const Text('Track Trip '),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mainBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    if (daysLeft(trip.date) < 5)
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.plus_one_outlined,
                                          size: 18,
                                        ),
                                        label: const Text('Renew Trip'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[600],
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
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
