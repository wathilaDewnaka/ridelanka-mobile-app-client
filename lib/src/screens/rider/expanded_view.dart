import 'package:client/global_variable.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ExpandedView extends StatefulWidget {
  const ExpandedView(
      {super.key,
      required this.driverName,
      required this.driverUid,
      required this.routeDetails,
      required this.image,
      required this.vehicleName,
      required this.price});

  final String driverUid;
  final String driverName;
  final String routeDetails;
  final String image;
  final String vehicleName;
  final String price;

  @override
  State<ExpandedView> createState() => _ExpandedViewState();
}

class _ExpandedViewState extends State<ExpandedView> {
  void confirmSubscription() async {
    DatabaseReference driverBookingsRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${widget.driverUid}/bookings');

    // Booking details for the driver
    Map<String, String> driverBookingDetails = {
      "userUid": firebaseUser!.uid,
      "subscriptionDate": DateTime.now().microsecondsSinceEpoch.toString(),
      "isActive": "false",
    };

    // Booking details for the user
    Map<String, String> userBookingDetails = {
      "driverUid": widget.driverUid,
      "subscriptionDate": DateTime.now().microsecondsSinceEpoch.toString(),
      "isActive": "false",
    };

    // Notification for the driver
    Map<String, String> driverNotifications = {
      "subscriptionDate": DateTime.now().microsecondsSinceEpoch.toString(),
      "isActive": "false",
      "isRead": "false"
    };

    try {
      // Save booking details in both user and driver nodes
      DatabaseReference driverDetails = driverBookingsRef.push();
      await driverDetails.set(driverBookingDetails);

      // References for user and driver bookings in Firebase
      DatabaseReference userBookingsRef = FirebaseDatabase.instance
          .ref()
          .child('users/${firebaseUser!.uid}/bookings/${driverDetails.key}');

      DatabaseReference driverNotification = FirebaseDatabase.instance
          .ref()
          .child(
              'drivers/${widget.driverUid}/notifications/${driverDetails.key}');

      await userBookingsRef.set(userBookingDetails);
      await driverNotification.set(driverNotifications);

      // Show success message
      createMessageBar(
        message: "Booking request sent successfully",
        title: "Success",
      );
    } catch (error) {
      // Handle errors and show an error message
      createMessageBar(
        message: "Something went wrong",
        title: "Error",
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Rides",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  widget.image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.driverName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "LKR ${double.parse(widget.price).toStringAsFixed(2)} / Month",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF0051ED),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: confirmSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0051ED),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue,
                      child: Text(
                        widget.driverName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.driverName.split(" ")[0],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.routeDetails,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
