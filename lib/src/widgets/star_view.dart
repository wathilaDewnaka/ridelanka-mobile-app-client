import 'package:flutter/material.dart';

class StarView extends StatelessWidget {
  final double rating;

  const StarView({
    Key? key,
    required this.rating,
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

            },
            child: Row(
              children: [
                Icon(Icons.visibility, size: 20, color: Colors.blue[500],),
                const SizedBox(width: 4),
                Text(
                  'View details',
                  style:  TextStyle(fontSize: 16, color: Colors.blue[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}