import 'package:client/src/models/trip_item.dart';
import 'package:flutter/material.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({Key? key}) : super(key: key);

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  static const Color mainBlue = Color(0xFF0051ED);
  String selectedFilter = 'All';

  final List<TripItem> trips = [
    TripItem(
      id: "T1001",
      source: "New York",
      destination: "Los Angeles",
      status: TripStatus.active,
      driverId: "",
      driverName: "Wathila Dewnaka",
      price: 299.99,
      vehicleType: "SUV",
      expDate: "",
    ),
    TripItem(
        id: "T1002",
        source: "San Francisco",
        destination: "Las Vegas",
        status: TripStatus.active,
        price: 199.99,
        driverId: "",
        driverName: "Wathila Dewnaka",
        vehicleType: "Sedan",
        expDate: ""),
    TripItem(
        id: "T1003",
        source: "Miami",
        destination: "Orlando",
        status: TripStatus.active,
        price: 149.99,
        driverId: "",
        driverName: "Wathila Dewnaka",
        vehicleType: "Premium",
        expDate: ""),
  ];

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
                "Trip History",
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
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Container()
      ),
    );
  }
}
