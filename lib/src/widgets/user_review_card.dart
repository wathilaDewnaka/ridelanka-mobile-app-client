import 'package:client/src/widgets/rating_bar_indicator.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class UserReviewCard extends StatelessWidget {
  final String userName;
  final String messsage;
  final String timestamp;
  final double rate;

  const UserReviewCard(
      {super.key,
      required this.userName,
      required this.messsage,
      required this.rate,
      required this.timestamp});

  @override
  Widget build(BuildContext context) {
    String firstLetter = userName.split(" ")[1][0];

    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF0051ED),
              radius: 25,
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
            VehicleRatingBarIndicator(rating: rate),
            const SizedBox(width: 10),
            Text("$rate/5.0", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 15),
        messsage.length > 100
            ? ReadMoreText(
                messsage,
                trimLines: 2,
                trimMode: TrimMode.Line,
                trimExpandedText: "...show less",
                trimCollapsedText: "show more",
                moreStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0051ED),
                ),
                lessStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0051ED),
                ),
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  messsage,
                  style: TextStyle(fontSize: 14),
                ),
              ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(timestamp, style: Theme.of(context).textTheme.bodyMedium),
        )
      ],
    );
  }
}
