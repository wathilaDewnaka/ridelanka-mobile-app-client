import 'package:client/src/widgets/overall_progress_indicator.dart';
import 'package:client/src/widgets/rating_bar_indicator.dart';
import 'package:client/src/widgets/user_review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsRatings extends StatefulWidget {
  const ReviewsRatings({super.key});

  @override
  State<ReviewsRatings> createState() => _ReviewsRatingsState();
}

class _ReviewsRatingsState extends State<ReviewsRatings> {
  void _showReviewDialog() {
    double _rating = 3.0;
    TextEditingController _reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Write a Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Increase width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rate your experience:"),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _rating = rating;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reviewController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Share your experience...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle review submission logic here
                print("Rating: \$_rating");
                print("Review: \${_reviewController.text}");
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0051ED),
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit"),
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
        title: const Text(
          'Reviews & Ratings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0051ED),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Ratings and reviews are verified and are from people who use the same type of device that you use'),
              const SizedBox(height: 10),
              const OverallVehicleRating(),
              const VehicleRatingBarIndicator(rating: 3.5),
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
        backgroundColor: const Color(0xFF0051ED),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
