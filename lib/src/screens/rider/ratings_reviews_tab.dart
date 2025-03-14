import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/models/ratings.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:client/src/widgets/progress_dialog.dart';
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
  List<Ratings> notificationAll = [];
  bool loading = true;
  bool canPostReview = false;

  void postNewReview(double rating, String text) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref("drivers/${widget.driverId}/ratings/reviews/${firebaseUser!.uid}");
    DatabaseReference databaseReference2 =
        FirebaseDatabase.instance.ref("drivers/${widget.driverId}/ratings");

    await databaseReference.set({
      'rate': rating,
      'message': text,
      'timestamp': DateTime.now().microsecondsSinceEpoch.toString()
    });

    Map<String, dynamic> mapOfData = await getAverageRating(widget.driverId);
    await databaseReference2
        .update({"total": mapOfData['average'], "count": mapOfData['count']});

    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: "Review posted successfully !",
        type: MessageType.success));
        
    await getRatings();
    Navigator.pop(context);
  }

  String formatDate(int microsecondsSinceEpoch) {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);

    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString().substring(2);

    return "$day/$month/$year";
  }

  Future<void> getRatings() async {
    DatabaseReference notifications = FirebaseDatabase.instance
        .ref()
        .child('drivers/${widget.driverId}/ratings/reviews');

    DataSnapshot mainNotificationsSnapshot = await notifications.get();

    if (mainNotificationsSnapshot.exists) {
      List<Ratings> newNotifications = [];

      for (var child in mainNotificationsSnapshot.children) {
        if (child.value is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> notificationData =
              Map<dynamic, dynamic>.from(child.value as Map);

          DatabaseReference driverRef =
              FirebaseDatabase.instance.ref().child('users/${child.key}');
          DataSnapshot snapshot = await driverRef.get();
          print(notificationData);

          if (snapshot.exists) {
            Map<dynamic, dynamic> userData =
                Map<dynamic, dynamic>.from(snapshot.value as Map);
            print(userData);

            try {
              Ratings notificationItem = Ratings.fromJson(
                  notificationData, child.key ?? "", userData['fullname']);

              newNotifications.add(notificationItem);
            } catch (e) {
              print(e);
            }
          }
        }
      }
      setState(() {
        notificationAll = newNotifications.reversed.toList();
        loading = false;
      });
    } else {
      print("No notifications found in the main path.");
    }
    bool canPost = await HelperMethods.checkIsUserSubscribed(firebaseUser!.uid);

    setState(() {
      loading = false;
      canPostReview = canPost;
    });
  }

  Future<Map<String, dynamic>> getAverageRating(String driverId) async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref("drivers/$driverId/ratings/reviews");

    DataSnapshot snapshot = await databaseReference.get();

    if (!snapshot.exists || snapshot.value == null) {
      return {'average': 5.0, 'count': 0};
    }

    double totalRating = 0.0;
    int count = 0;

    Map<dynamic, dynamic> ratings = snapshot.value as Map<dynamic, dynamic>;

    ratings.forEach((key, value) {
      print(ratings);
      if (value is Map && value.containsKey('rate')) {
        totalRating += (value['rate'] as num).toDouble();
        count++;
      }
    });

    double averageRating = count > 0 ? totalRating / count : 5.0;
    return {'average': averageRating, 'count': count};
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Please wait...'),
      );

      // Initialize async tasks
      getRatings().then((_) {
        // After tasks are complete, dismiss the dialog
        print("object");
        Navigator.pop(context);
      }).catchError((error) {
        Navigator.pop(context);
      });
    });
  }

  void _showReviewDialog() {
    double _rating = 3.0;
    TextEditingController _reviewController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Write a Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 5, // Increase width
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
                Navigator.pop(context);
                postNewReview(_rating, _reviewController.text);
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
      backgroundColor: const Color(0xFF0051ED),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF0051ED),
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              elevation: 0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 17.0),
              child: Text(
                "Ratings & Reviews",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: notificationAll.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 80), // Spacing for floating button
                      itemCount: notificationAll.length,
                      itemBuilder: (context, index) {
                        final Ratings review = notificationAll[index];
                        print(review);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: UserReviewCard(
                            userName: review.fullname,
                            timestamp: formatDate(int.parse(review.timestamp)),
                            messsage: review.description,
                            rate: review.count,
                          ),
                        );
                      },
                    )
                  : !loading
                      ? const SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.only(top: 16.0, left: 8),
                            child: Text(
                              "No reviews or ratings found",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        )
                      : const SizedBox(height: 100, width: double.infinity),
            ),
          ],
        ),
      ),
      floatingActionButton: canPostReview
          ? FloatingActionButton(
              onPressed: _showReviewDialog,
              backgroundColor: const Color(0xFF0051ED),
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
    );
  }
}
