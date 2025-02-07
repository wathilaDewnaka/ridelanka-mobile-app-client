import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/globle_variable.dart';
import 'package:client/src/methods/request_helper.dart';
import 'package:client/src/models/address.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class HelperMethods {
  static Future<String> findCordinateAddress(Position position, context) async {
    print("this is position ");
    print(position);
    String placeAddress = '';

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${mapKey}';

    var response = await RequestHelper.getRequest(url);
    print('this is res :');
    print(response);
    print(url);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
      print('this is res :' + placeAddress);
      Address pickupAddress = new Address(
          placeId: '',
          latitude: position.latitude,
          longituge: position.longitude,
          placeName: placeAddress,
          placeFormattedAddress: '');

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }

    return placeAddress;
  }
}
