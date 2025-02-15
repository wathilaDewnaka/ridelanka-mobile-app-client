import 'package:client/src/models/available_vehicles.dart';
import 'package:client/src/models/vehicles.dart';
import 'package:client/src/screens/rider/expanded_view.dart';
// import 'package:client/src/screens/rider/expanded_view.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:client/src/methods/helper_methods.dart';

class VehicleDetails extends StatefulWidget {
  VehicleDetails({super.key, required this.isStudent});

  static const String id = "vehicles";
  final bool isStudent;

  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  List<Vehicle> vehiclesAll = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isLoading = true;
      });
      // Show the dialog
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Please wait...'),
      );

      // Initialize async tasks
      _initializeAsyncTasks().then((_) {
        // After tasks are complete, dismiss the dialog
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
      }).catchError((error) {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  Future<void> _initializeAsyncTasks() async {
    List<AvailableVehicles> vehicles =
        await HelperMethods.findNearestVehicles(context, widget.isStudent);
    final databaseReference = FirebaseDatabase.instance.ref("drivers");

    try {
      List<Vehicle> fetchedVehicles = [];

      for (AvailableVehicles uid in vehicles) {
        final vehicleSnapshot = await databaseReference.child(uid.uid).get();

        if (vehicleSnapshot.exists) {
          final Map<String, dynamic> vehicleData =
              Map<String, dynamic>.from(vehicleSnapshot.value as Map);
          fetchedVehicles.add(Vehicle.fromJson(vehicleData, uid.uid, uid.startKm, uid.endKm, uid.startPlaceName, uid.endPlaceName));
        } else {
          print("No data found for UID: $uid");
        }
      }

      setState(() {
        vehiclesAll = fetchedVehicles;
      });
    } catch (error) {
      print("Error fetching data: $error");
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
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            isLoading == false && vehiclesAll.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: Icon(
                              Icons.directions_car,
                              size: 50,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "No Vehicles Available",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "We apologize, but there are currently no vehicles available in your area. We're working to expand our coverage.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 2,
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Column(
                                children: [
                                  const Text(
                                    "Need assistance?",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 32,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          // Add call functionality here
                                        },
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Contact RideLanka Support",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const Text(
                                              "+94 77 123 4567",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            Expanded(
              child: ListView.builder(
                itemCount: vehiclesAll.length,
                itemBuilder: (context, index) {
                  final ride = vehiclesAll[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExpandedView(
                                  driverName: ride.driverName,
                                  driverUid: ride.driverUid,
                                  routeDetails: ride.routeDetails,
                                  image: ride.vehicleImage,
                                  vehicleName: ride.vehicleNo,
                                  price: ride.vehiclePrice,
                                  startKm: ride.startKm,
                                  endKm: ride.endKm,
                                  startPl: ride.startPlaceName,
                                  endPl: ride.endPlaceName,)));
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blue.shade200,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                ride.vehicleImage,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ride.vehicleNo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    ride.driverName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "LKR ${ride.vehiclePrice.toStringAsFixed(2)} / Month",
                                    style: const TextStyle(
                                      color: Color(0xFF0051ED),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    ride.routeDetails,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (starIndex) => Icon(
                                        starIndex < 4
                                            ? Icons.star
                                            : Icons.star_half,
                                        color: Colors.amber,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            isLoading == false && vehiclesAll.length < 4
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icon Section
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.orange.withOpacity(0.2),
                              child: const Icon(
                                Icons.directions_car,
                                color: Colors.orange,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Text Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Only ${vehiclesAll.length} vehicles found nearby",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      text: "Need help? ",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Call +94 77 123 4567",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "We’re here to assist you in finding the right ride or resolving any issues you might face.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
