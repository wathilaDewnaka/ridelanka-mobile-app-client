import 'package:flutter/material.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  String getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/driver_dashboard_images/driverhomebg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
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
                    children: [
                      Text(
                        "${getGreeting()},",
                        style: const TextStyle(
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
                  iconImage: 'assets/images/driver_dashboard_images/van.png',
                  label: "Add",
                  onPressed: () {
                    print("Add pressed");
                  },
                ),
                MenuButton(
                  iconImage:
                      'assets/images/driver_dashboard_images/attendance.png',
                  label: "Attendance",
                  onPressed: () {
                    print("Attendance pressed");
                  },
                ), // attendance button

                MenuButton(
                  iconImage: 'assets/images/driver_dashboard_images/view.png',
                  label: "View",
                  onPressed: () {
                    print("View pressed");
                  },
                ), // view button

                MenuButton(
                  iconImage:
                      'assets/images/driver_dashboard_images/profile.png',
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

// Menu Button Widget
class MenuButton extends StatelessWidget {
  final String iconImage;
  final String label;
  final VoidCallback onPressed;
  final bool isHighlighted;

  const MenuButton({
    super.key,
    required this.iconImage,
    required this.label,
    required this.onPressed,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.white,
        shadowColor: Colors.blueAccent.withOpacity(0.3),
        elevation: isHighlighted ? 10 : 6, // Highlight effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isHighlighted ? Colors.blueAccent : Colors.grey.shade300,
            width: 2,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconImage, height: 48, width: 48),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
