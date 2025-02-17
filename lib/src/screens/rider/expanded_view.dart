import 'package:client/global_variable.dart';
import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/widgets/message_bar.dart';
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
  bool isButtonDisabled = false;
  int remainingTime = 0; // Remaining time in seconds
  int totalDisableTime = 3; // Total disable time in seconds

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
        setState(() {
          isButtonDisabled = true;
          remainingTime = totalDisableTime - elapsedTime;
        });

        Future.delayed(Duration(seconds: (remainingTime - elapsedTime).toInt()),
            () {
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

    String? pickupLocation = Provider.of<AppData>(context, listen: false)
        .pickupAddress
        .placeName;
    String? destLocation = Provider.of<AppData>(context, listen: false)
        .destinationAddress
        .placeName;

    _saveButtonState(); // Save the timestamp

    Map<String, String> userBookingDetails = {
      "start": pickupLocation ?? "",
      "end": destLocation ?? "",
      "price": " widget.price",
      "driverName": "",
      "vehicleName": "",
      "driverUid": widget.driverUid,
      "subscriptionDate": DateTime.now().microsecondsSinceEpoch.toString(),
      "isActive": "Pending",
    };

    Map<String, String> driverNotifications = {
      "title": "Booking Request",
      "description": "New booking request for the vehicle registered",
      "icon": "Icons.new",
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

      Navigator.pop(context);

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
                      "LKR ${widget.price} / Month",
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
