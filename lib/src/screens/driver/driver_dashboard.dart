import 'package:flutter/material.dart';

class DriverHome {
  const DriverHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header Section with Background Image
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
              ),
              Positioned(
                top: 150,
                left: 20,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Good morning,",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Wathila Karunathilake",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          // Button Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                MenuButton(
                  iconImage: '',
                  label: "Add",
                  onPressed: () {
                    print("Add pressed");
                  },
                ),
                MenuButton(
                  iconImage: '',
                  label: "Attendance",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendancePage(),
                      ),
                    );
                    print("Attendance pressed");
                  },
                ), // attendance button

                MenuButton(
                  iconImage: '',
                  label: "View",
                  onPressed: () {
                    print("View pressed");
                  },
                ), // view button

                MenuButton(
                  iconImage: '',
                  label: "Profile",
                  onPressed: () {
                    print("Profile pressed");
                  },
                ), //profile button
              ],
            ),
          ),
        ],
      ),
    );
  }
}
