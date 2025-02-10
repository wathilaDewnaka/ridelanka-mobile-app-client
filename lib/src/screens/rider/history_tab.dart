import 'package:client/src/models/trip_item.dart';
import 'package:flutter/material.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  static const Color mainBlue = Color(0xFF0051ED);
  String selectedFilter = 'All';

  final List<TripItem> trips = [
    TripItem(
      id: "T1001",
      source: "New York",
      destination: "Los Angeles",
      status: TripStatus.inactive,
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

  List<TripItem> getFilteredTrips() {
    switch (selectedFilter) {
      case 'Active Rides':
        return trips.where((trip) => trip.status == TripStatus.active).toList();
      case 'Inactive Rides':
        return trips
            .where((trip) => trip.status == TripStatus.inactive)
            .toList();
      default:
        return trips;
    }
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'Active Rides',
                        'Inactive Rides',
                      ]
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
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: trip.status == TripStatus.active
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
                                          color:
                                              trip.status == TripStatus.active
                                                  ? mainBlue.withOpacity(0.1)
                                                  : Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          trip.status == TripStatus.active
                                              ? 'Active'
                                              : 'Completed',
                                          style: TextStyle(
                                            color:
                                                trip.status == TripStatus.active
                                                    ? mainBlue
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
                                        trip.vehicleType,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rs.${trip.price.toStringAsFixed(2)}/Month',
                                    style: TextStyle(
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
                                    child: Icon(
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
                                              "Expires in 30 days",
                                              style: TextStyle(
                                                color: Colors.grey[500],
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
                            ],
                          ),
                        ),
                        if (trip.status == TripStatus.active)
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
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        trips[index].driverName[0],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      trips[index].driverName.split(" ")[0],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.visibility, size: 18),
                                  label: const Text('Track Trip'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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
}
