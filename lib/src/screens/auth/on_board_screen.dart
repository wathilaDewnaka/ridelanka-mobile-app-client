import 'package:client/src/screens/auth/mobile_register_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MobileRegisterScreen(),
                      ),
                    );
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
      ),
    );
  }
}

class OnBoard {
  final String image, title, description;

  OnBoard({
    required this.description,
    required this.title,
    required this.image,
  });
}

// List of data for the onboarding screen
List<OnBoard> data = [
  OnBoard(
      description:
          "Find school or staff services easily. Get quick access to support and resources for your needs.",
      title: "Anywhere you are",
      image: "assets/images/on_boarding_images/image_1.png"),
  OnBoard(
      description:
          "Help safely transport students and staff with reliable routes and easy scheduling at your fingertips.",
      title: "Join Our Team of Driver",
      image: "assets/images/on_boarding_images/image_2.png"),
  OnBoard(
      description:
          "Easily book safe, on-time rides for students and staff, with real-time tracking and reliable drivers.",
      title: "School & Staff Rides",
      image: "assets/images/on_boarding_images/image_3.png"),
];

class OnBoardData extends StatelessWidget {
  const OnBoardData({
    super.key,
    required this.image,
    required this.description,
    required this.title,
  });

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250), // Replace with valid image path
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24, // Adjust size to be more professional
                ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600], // Grey color for the description
                fontSize: 16, // Slightly smaller font for description
                fontWeight: FontWeight.normal, // Lighter weight for description
              ),
            ),
          ),
        ],
      ),
    );
  }
}
