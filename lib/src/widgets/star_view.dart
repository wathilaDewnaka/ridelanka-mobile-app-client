import 'package:client/src/screens/rider/ratings_reviews_tab.dart';
import 'package:flutter/material.dart';

class StarView extends StatelessWidget {
  final double rating;
  final String driverUid;

  const StarView({
    Key? key,
    required this.rating,
    required this.driverUid
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          // Views counter
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ReviewsRatings(driverId: driverUid)));
            },
            child: Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 20,
                  color: Colors.blue[800],
                ),
                const SizedBox(width: 4),
                Text(
                  'View details',
                  style: TextStyle(fontSize: 16, color: Colors.blue[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
