
import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250), // Replace with valid image path
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 26, // Professional font size for the title
                ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600], // Grey color for the description
                fontSize: 16, // Slightly smaller font for description
                height: 1.5, // Line height for readability
              ),
            ),
          ),
        ],
      ),
    );
  }
}
