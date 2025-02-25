import 'package:flutter/material.dart';

class ReviewsRatings extends StatefulWidget {
  const ReviewsRatings({super.key});

  @override
  State<ReviewsRatings> createState() => _ReviewsRatingsState();
}

class _ReviewsRatingsState extends State<ReviewsRatings> {
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
              Row(
                children: [
                  Text('4.8', style: Theme.of(context).textTheme.displayLarge),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('5',
                                style: Theme.of(context).textTheme.bodyMedium),
                            Expanded(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: LinearProgressIndicator(
                                  value: 0.5,
                                  minHeight: 25,
                                  backgroundColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(7),
                                  valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF0051ED)),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
