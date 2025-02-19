import 'package:client/src/methods/helper_methods.dart';
import 'package:flutter/material.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  String? driverName;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    getName();
  }

  void getName() async {
    String? name = await HelperMethods.getDriverName("uid");
    setState(() {
      driverName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 455,
            child: Container(
              height: 1000, // Fixed height for the image container
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/driver_dashboard_images/driverhomebg.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Greeting Card
          Positioned(
            top: 210,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                    driverName ?? "Mr. NaN",
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

          // Red Section - Fully dynamic
          Positioned(
            top: 305,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0, // Ensure proper button sizing
                  children: [
                    MenuButton(
                      iconImage:
                          'assets/images/driver_dashboard_images/attendance.png',
                      label: "Rides",
                      onPressed: () {
                        print("Rides pressed");
                      },
                    ),
                    MenuButton(
                      iconImage:
                          'assets/images/driver_dashboard_images/notification.png',
                      label: "View",
                      onPressed: () {
                        print("View pressed");
                      },
                    ),
                    MenuButton(
                      iconImage:
                          'assets/images/driver_dashboard_images/van.png',
                      label: "Add",
                      onPressed: () {
                        print("Add pressed");
                      },
                    ),
                    MenuButton(
                      iconImage:
                          'assets/images/driver_dashboard_images/profile.png',
                      label: "Profile",
                      onPressed: () {
                        print("Profile pressed");
                      },
                    ),
                  ],
                ),
              ),
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
        elevation: isHighlighted ? 10 : 6,
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
