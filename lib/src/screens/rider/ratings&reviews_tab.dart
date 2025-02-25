import 'package:client/src/widgets/overall_progress_indicator.dart';
import 'package:client/src/widgets/rating_bar_indicator.dart';
import 'package:client/src/widgets/user_review_card.dart';
import 'package:flutter/material.dart';

class ReviewsRatings extends StatefulWidget {
  const ReviewsRatings({super.key});

  @override
  State<ReviewsRatings> createState() => _ReviewsRatingsState();
}

class _ReviewsRatingsState extends State<ReviewsRatings> {
  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Write a Review"),
          content: TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Share your experience...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Handle review submission logic here
                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews & Ratings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0051ED),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Ratings and reviews are verified and are from people who use the same type of device that you use'),
              SizedBox(height: 10),
              OverallVehicleRating(),
              VehicleRatingBarIndicator(rating: 3.5),
              Text('12,111', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 19),
              const UserReviewCard(userName: "Thisuri Nethma"),
              const UserReviewCard(userName: "Thisuri Nethma"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReviewDialog,
        backgroundColor: Color(0xFF0051ED),
        child: Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
