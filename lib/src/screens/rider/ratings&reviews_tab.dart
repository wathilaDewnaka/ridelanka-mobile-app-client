import 'package:client/global_variable.dart';
import 'package:client/src/widgets/overall_progress_indicator.dart';
import 'package:client/src/widgets/rating_bar_indicator.dart';
import 'package:client/src/widgets/user_review_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsRatings extends StatefulWidget {
  const ReviewsRatings({super.key, required this.driverId});

  final String driverId;

  @override
  State<ReviewsRatings> createState() => _ReviewsRatingsState();
}

class _ReviewsRatingsState extends State<ReviewsRatings> {
  void postNewReview(double rating, String text) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref("drivers/${widget.driverId}/ratings/${firebaseUser!.uid}");
    DatabaseReference databaseReference2 =
        FirebaseDatabase.instance.ref("drivers/${widget.driverId}/ratings");

    await databaseReference.set({'rate': rating, 'message': text});
    await databaseReference2.update({"total": 0, "count": 33});
  }

  Future<Map<String, dynamic>> getAverageRating(String driverId) async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref("drivers/$driverId/ratings");

    DataSnapshot snapshot = await databaseReference.get();

    if (!snapshot.exists || snapshot.value == null) {
      return {'average': 5.0, 'count': 0};
    }

    double totalRating = 0.0;
    int count = 0;

    Map<dynamic, dynamic> ratings = snapshot.value as Map<dynamic, dynamic>;

    ratings.forEach((key, value) {
      if (value is Map && value.containsKey('rate')) {
        totalRating += (value['rate'] as num).toDouble();
        count++;
      }
    });

    double averageRating = count > 0 ? totalRating / count : 0.0;

    return {'average': averageRating, 'count': count};
  }

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
                postNewReview(_rating, _reviewController.text);
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
