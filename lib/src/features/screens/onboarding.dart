import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Correctly access MediaQuery inside build method
    final size = MediaQuery.of(context).size;
    const double tDefaultSize = 16.0;

    return Scaffold(
      body: LiquidSwipe(
        pages: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(tDefaultSize),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  "assets/images/on_boarding_images/image_1.png",
                  height: size.height * 0.5,
                ),
                // Text widget with corrected TextStyle
                Column(
                  children: [
                    Text(
                      "Anywhere you are",
                      style: Theme.of(context).textTheme.headlineSmall, // Correct style usage
                    ),
                    Text(
                        "Find school or staff services easily. Get quick access to support and resources for your needs.",
                        textAlign: TextAlign.center
                    ),
                  ],
                ),
                Text("1/3"),
                SizedBox(height: 50.0)
              ],
            ),
          ),
          // Second page
          Container(
            color: Colors.green,
            child: const Center(
              child: Text(
                "Explore Amazing Featuress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
