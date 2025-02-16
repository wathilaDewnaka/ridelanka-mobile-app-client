import 'package:client/src/models/on_board.dart';
import 'package:client/src/screens/auth/mobile_login_screen.dart';
import 'package:client/src/widgets/on_board_data.dart';
import 'package:flutter/material.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OnBoardLoadingScreenState();
  }
}

class _OnBoardLoadingScreenState extends State<OnBoardScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MobileLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: data.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnBoardData(
                        image: data[index].image,
                        title: data[index].title,
                        description: data[index].description,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentIndex == data.length - 1) {
                        // Navigate to MobileLoginScreen on the last page
                        navigateToLogin();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color(0xFF0051ED),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: Icon(
                      currentIndex == data.length - 1
                          ? Icons.check // Change icon on the last page
                          : Icons.arrow_forward,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: navigateToLogin,
                child: Text(
                  "Skip",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<OnBoard> data = [
  OnBoard(
      description:
          "Find school or staff services easily. Get quick access to support and resources for your needs.",
      title: "Anywhere you are",
      image: "assets/images/on_boarding_images/image_1.png"),
  OnBoard(
      description:
          "Help safely transport students and staff with reliable routes and easy scheduling at your fingertips.",
      title: "Join Our Team of Drivers",
      image: "assets/images/on_boarding_images/image_2.png"),
  OnBoard(
      description:
          "Easily book safe, on-time rides for students and staff, with real-time tracking and reliable drivers.",
      title: "School & Staff Rides",
      image: "assets/images/on_boarding_images/image_3.png"),
];
