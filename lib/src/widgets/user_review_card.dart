import 'package:client/src/widgets/rating_bar_indicator.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class UserReviewCard extends StatelessWidget {
  final String userName;

  const UserReviewCard({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF0051ED),
              radius: 30,
              child: Text(
                firstLetter,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              userName,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            VehicleRatingBarIndicator(rating: 4),
            const SizedBox(width: 10),
            Text('01 Nov 2023', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 15),
        ReadMoreText(
          "Excellent experience! The app is user-friendly, well-designed, and runs smoothly. I love how intuitive the interface is, making it easy to navigate through different features. Great job!",
          trimLines: 2,
          trimMode: TrimMode.Line,
          trimExpandedText: "...show less",
          trimCollapsedText: "show more",
          moreStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0051ED),
          ),
          lessStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0051ED),
          ),
        ),
      ],
    );
  }
}
