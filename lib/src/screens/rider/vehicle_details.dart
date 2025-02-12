import 'package:client/src/models/vehicles.dart';
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
    List<String> vehicles =
        await HelperMethods.findNearestVehicles(context, widget.isStudent);
    final databaseReference = FirebaseDatabase.instance.ref("drivers");

    try {
      List<Vehicle> fetchedVehicles = [];

      for (String uid in vehicles) {
        final vehicleSnapshot = await databaseReference.child(uid).get();

        if (vehicleSnapshot.exists) {
          final Map<String, dynamic> vehicleData =
              Map<String, dynamic>.from(vehicleSnapshot.value as Map);
          fetchedVehicles.add(Vehicle.fromJson(vehicleData, uid));
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
            
            Expanded(
              child: ListView.builder(
                itemCount: vehiclesAll.length,
                itemBuilder: (context, index) {
                  final ride = vehiclesAll[index];
                  return GestureDetector(
                    onTap: () {},
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
                                    ride.driverName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Rs. ${ride.vehiclePrice}/Month",
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
            )
          ],
        ),
      ),
    );
  }
}
