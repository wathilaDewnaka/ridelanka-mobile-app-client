
import 'package:client/src/data_provider/prediction.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  PredictionTile({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        print("you clicked the place tile");
        print(prediction.mainText);
      },
      child: Container(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 7,
            ),
            Row(
              children: <Widget>[
                const Icon(
                  OMIcons.locationOn,
                  color: Color(0xFFadadad),
                  size: 30,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        prediction.mainText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        prediction.secondaryText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFFadadad)),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 7,
            ),
          ],
        ),
      ),
    );
  }
}
