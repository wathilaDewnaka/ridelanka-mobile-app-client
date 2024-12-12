import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OnBoardLoadingScreenState();
  }
}

class _OnBoardLoadingScreenState extends State<OnBoardScreen> {
  late PageController _pageController;

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
                itemCount: data.length, // Using the length of the data list
                itemBuilder: (context, index) {
                  return OnBoardData(
                    image: data[index].image, // Provide the image
                    title: data[index].title, // Provide the title
                    description: data[index].description, // Provide the description
                  );
                },
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(), backgroundColor: Colors.blue, // Blue background color for the button
                  padding: EdgeInsets.all(12), // Padding for the button to make it circular
                  side: BorderSide(color: Colors.blue, width: 2), // Border color and thickness
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white, // White color for the arrow icon
                  size: 30, // Size of the arrow icon
                ),
              ),
            ),
            SizedBox(height: 20), // Optional: space between button and bottom
          ]
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
  OnBoard(description: "Find school or staff services easily. Get quick access to support and resources for your needs.", title: "Anywhere you are", image: "assets/images/on_boarding_images/image_1.png"),
  OnBoard(description: "Help safely transport students and staff with reliable routes and easy scheduling at your fingertips.", title: "Join Our Team of Driver", image: "assets/images/on_boarding_images/image_2.png"),
  OnBoard(description: "Easily book safe, on-time rides for students and staff, with real-time tracking and reliable drivers.", title: "School & Staff Rides", image: "assets/images/on_boarding_images/image_3.png"),
];

class OnBoardData extends StatelessWidget {
  const OnBoardData({
    Key? key,
    required this.image,
    required this.description,
    required this.title,
  }) : super(key: key);

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600], // Grey color for the description
            fontSize: 16, // Slightly smaller font for description
            fontWeight: FontWeight.normal, // Lighter weight for description
          ),
        ),
      ],
    );
  }
}
