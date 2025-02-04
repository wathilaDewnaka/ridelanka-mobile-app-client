import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/data_provider/prediction.dart';
import 'package:client/src/globle_variable.dart';
import 'package:client/src/methods/request_helper.dart';
import 'package:client/src/models/address.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  PredictionTile({required this.prediction});

  void getPlacedDetails(String placeId, context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: "Please wait..."));

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }

    if (response['status'] == 'OK') {
      print("get the details");
      Address thisPlace = Address(
          placeId: placeId,
          latitude: response['result']['geometry']['location']['lat'],
          longituge: response['result']['geometry']['location']['lng'],
          placeName: response['result']['name'],
          placeFormattedAddress: '');

      print("place : up");
      print(thisPlace.toString());
      Provider.of<AppData>(context, listen: false)
          .updateDestinationAddress(thisPlace);
      print("place :");
      print(thisPlace.placeName);

      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        print("you clicked the place tile");
        print(prediction.mainText);
        getPlacedDetails(prediction.placeId, context);
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
