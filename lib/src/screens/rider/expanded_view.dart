import 'package:client/global_variable.dart';
import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/methods/push_notification_service.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:client/src/widgets/rating_bar_indicator.dart';
import 'package:client/src/widgets/star_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpandedView extends StatefulWidget {
  const ExpandedView(
      {super.key,
      required this.driverName,
      required this.driverUid,
      required this.routeDetails,
      required this.image,
      required this.vehicleName,
      required this.price,
      required this.startPl,
      required this.endPl,
      required this.startKm,
      required this.seatCap,
      required this.exp,
      required this.lang,
      required this.mainPoints,
      required this.endKm,
      required this.vehicleNo,
      required this.vehType,
      required this.rate,
      required this.count});

  final String driverUid;
  final String driverName;
  final String routeDetails;
  final String image;
  final String vehicleName;
  final String vehicleNo;
  final double price;
  final String lang;
  final String exp;
  final String seatCap;
  final String mainPoints;
  final String vehType;

  final int startKm;
  final int endKm;
  final String startPl;
  final String endPl;
  final double rate;
  final int count;

  @override
  State<ExpandedView> createState() => _ExpandedViewState();
}

class _ExpandedViewState extends State<ExpandedView> {
  bool isButtonDisabled = false;
  int remainingTime = 0; // Remaining time in seconds
  int totalDisableTime = 400; // Total disable time in seconds

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadButtonState();
  }

  void _loadButtonState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastDisabledTimestamp = prefs.getInt('lastDisabledTimestamp') ?? 0;

    if (lastDisabledTimestamp != 0) {
      DateTime lastDisabledTime =
          DateTime.fromMillisecondsSinceEpoch(lastDisabledTimestamp);
      int elapsedTime = DateTime.now().difference(lastDisabledTime).inSeconds;

      if (elapsedTime < totalDisableTime) {
        if (mounted) {
          setState(() {
            isButtonDisabled = true;
            remainingTime = elapsedTime;
          });
        }

        Future.delayed(Duration(seconds: (remainingTime).toInt()), () {
          setState(() {
            isButtonDisabled = false; // Re-enable the button
            remainingTime = 0; // Reset remaining time
          });

          // Clear the saved timestamp
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove('lastDisabledTimestamp');
          });
        });
      } else {
        setState(() {
          isButtonDisabled = false;
          remainingTime = 0;
        });
      }
    }
  }

  void _saveButtonState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        'lastDisabledTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  void confirmSubscription() async {
    // Show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );

    if (isButtonDisabled) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        message: "Wait atleast 5 minutes before making new booking",
        title: "Error",
        type: MessageType.error,
      ));
      Navigator.pop(context);
      return;
    }

    setState(() {
      isButtonDisabled = true; // Disable the button
      remainingTime = totalDisableTime;
    });

    String? pickupLocation =
        Provider.of<AppData>(context, listen: false).pickupAddress.placeName;
    String? destLocation = Provider.of<AppData>(context, listen: false)
        .destinationAddress
        .placeName;

    _saveButtonState(); // Save the timestamp

    Map<dynamic, dynamic> userBookingDetails = {
      "start": pickupLocation,
      "end": destLocation,
      "driverUid": widget.driverUid,
      "subscriptionDate": DateTime.now()
          .add(const Duration(days: 30))
          .microsecondsSinceEpoch
          .toString(),
      "isActive": "Pending",
      "location": {
        "startLat":
            Provider.of<AppData>(context, listen: false).pickupAddress.latitude,
        "startLng": Provider.of<AppData>(context, listen: false)
            .pickupAddress
            .longituge,
        "endLat": Provider.of<AppData>(context, listen: false)
            .destinationAddress
            .latitude,
        "endLng": Provider.of<AppData>(context, listen: false)
            .destinationAddress
            .longituge
      }
    };

    try {
      DatabaseReference fcm = FirebaseDatabase.instance
          .ref()
          .child("drivers/${widget.driverUid}/token");
      DataSnapshot snapshot = await fcm.get();
      String token = snapshot.value as String;
      PushNotificationService.sendNotificationsToUsers(token,
          "Driver Booking Request", "New booking request checkn details");
    } catch (e) {
      print(e);
    }

    Map<String, String> driverNotifications = {
      "title": "Booking Request",
      "description":
          "New booking request from $pickupLocation to $destLocation",
      "icon": "new",
      "date": DateTime.now().microsecondsSinceEpoch.toString(),
      "isRead": "false",
      "isActive": "${firebaseUser!.uid}"
    };

    try {
      // References for user and driver bookings in Firebase
      DatabaseReference userBookingsRef = FirebaseDatabase.instance
          .ref()
          .child('users/${firebaseUser!.uid}/bookings');

      DatabaseReference userData = userBookingsRef.push();
      await userData.set(userBookingDetails);

      DatabaseReference driverNotification = FirebaseDatabase.instance
          .ref()
          .child('drivers/${widget.driverUid}/notifications/${userData.key}');

      await driverNotification.set(driverNotifications);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const RiderNavigationMenu(
                selectedIndex: 2)), // The route name for the login screen
        (route) => false, // Remove all routes
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
          message: "Booking request sent successfully",
          title: "Success",
          type: MessageType.success));
    } catch (error) {
      // Handle errors and show an error message
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        message: "Something went wrong",
        title: "Error",
        type: MessageType.error,
      ));
    }

    Future.delayed(Duration(seconds: totalDisableTime), () {
      if (mounted) {
        setState(() {
          isButtonDisabled = false; // Re-enable the button
          remainingTime = 0; // Reset remaining time
        });
      }

      // Clear the saved timestamp
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('lastDisabledTimestamp');
      });
    });
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
      backgroundColor: Color(0xFF0051ED),
      body: Container(
        padding: EdgeInsets.only(top: 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
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

              // Driver Information
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicleName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        VehicleRatingBarIndicator(rating: widget.rate),
                        Text(" ${widget.rate}/5.0 (${widget.count})")
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "LKR ${widget.price.toStringAsFixed(2)} / Month",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF0051ED),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Button (Full Width)
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

              SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue,
                              child: Text(
                                widget.driverName.contains(" ")
                                    ? widget.driverName.split(" ")[1][0]
                                    : widget.driverName[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.driverName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Vehicle Type"),
                                Text(widget.vehType)
                              ],
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Seat Capacity"),
                                Text(widget.seatCap)
                              ],
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Driver Experience"),
                                Text("${widget.exp} Years")
                              ],
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Prefered Lanuage"),
                                Text(widget.lang)
                              ],
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Main Start and End"),
                                SizedBox(
                                    width: 170,
                                    child: Text(
                                      widget.mainPoints,
                                      textAlign: TextAlign.end,
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          textAlign: TextAlign.justify,
                          "According to RideLanka this vehicle is ${widget.startKm == 0 ? "less than 1" : widget.startKm} KM near to your start location and ${widget.endKm == 0 ? "less than 1" : widget.endKm} KM near to your end location. Accordingly pickup is nearby ${widget.startPl} and drop is at ${widget.endPl}. Contact your Driver before the booking to make sure about details. Vehicle number is ${widget.vehicleNo}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Route Details
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            textAlign: TextAlign.justify,
                            widget.routeDetails,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      StarView(rating: widget.rate, driverUid: widget.driverUid)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
