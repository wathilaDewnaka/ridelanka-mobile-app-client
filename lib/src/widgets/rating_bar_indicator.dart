import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class VehicleRatingBarIndicator extends StatelessWidget {
  const VehicleRatingBarIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: 4.5,
      itemSize: 20,
      unratedColor: Colors.grey,
      itemBuilder: (_, __) => Icon(Icons.star, color: Colors.amber),
    );
  }
}
