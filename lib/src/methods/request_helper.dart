import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestHelper {
  static Future<dynamic> getRequest(String url) async {
    try {
      Uri uri = Uri.parse(url);

      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        return decodedData;
      } else {
        return 'failed';
      }
    } catch (e) {
      return 'failed';
    }
  }

  static Future<String> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);

      return jsonData['response'] ?? 'Something went wrong !';
    } else {
      return 'Something went wrong !';
    }
  }
}
