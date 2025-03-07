import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class PushNotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "ridelanka-cb659",
      "private_key_id": "ed8f2173fc68a43c0e8f5a6985fc3e69e5294f2e",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDCYaiV9TiIVYbH\nS592pZvjVCt7+lzC8VeUIzvjjB//cZsmcRkX0DWApdfXe5fTFh8NfpvsMPBJ6QTj\nT2VhO1BA/+85PZAnUieTbfUO5txZiLSksrhbPbPu7+J6Yliz8+N4Cn7DXhCfAQId\n2pBBhWOZQis41f30WoZk8yRlyBCly4kM1vd8u4Fg4OnXF/Fh/7ujU9d5JQAPrFIs\nnqPWlC57ts5/lEBcYnaTNYFm2zWnuH3yDcabkntLwe/PQgEGIPb6YkCTlwIWmBc7\nI2ckWVQJgZUG/n0R90kkQQCY0yyv/VFeHCTNVyVK1RJDwNz96pu5EusGpCxUvnEA\nfPZqKcojAgMBAAECggEAIHJDvVBTEPLRzheR9TCcrlwg7A91B3dYqpodB5UezDlu\n8AJF8YMoQyKrvkTbqXkSUuLU7R6YJYY3cigRIKNReKAgEvpzQxUEFShwFP41Pt7C\nZJGOk3Bfxh0VvV8INnWZ/TInSb48YQY+j7Qpiz5US0NPyqtxuiWYNGafpzu3h60A\nSEP3vRtfAhDs+2qRbUgb1B1i4fRUduIOZ5LGo5JUUqtAU8j2gJaM+lZaypxz1evn\nXeRwCy/XsWhcNQ+L0C5lm4tYtQgApUOPW2jGPfCLTFTa+WWwiJ9tKgjmeKRONek/\nhWQSilxAAi/UGxWYqQeyQ75F9HEvIZHd0CrkdmD73QKBgQD9/Qv8X3k/zOhyLvTc\nu9Kn1rTQtObxsZrAHe7omNpsc4VbZsWnWaFC1uRpZonxeBDXgYlPFpdfLHWvLqOs\no8f9x15DJpfVylxFnShQFyPJZnYPAoSLONl6wyuHQyKaUobxy9qC2WWGbRHINMeC\nQVFCnRtP3hdBlsXX2h2977+aPQKBgQDD68KyW4QI77GtS+wpQfJoSPKvxoTh6VSA\n7KsRznzVs3Fw33d6qGyFv6HKZCRrMwTi7OCTkCtgzLOFMgpvfUoVV0P2rWSCQbi7\nm9kkiZq/SAWDje67L87Xz5h8nCUdRVwhVPo/hy3J6ihga6yRkDW4paMQUwhSnXdv\nz3pFBtYb3wKBgQCMGWbhIPDKxoZ5ZXlfwKLkPcSjUwYIz8TisCA2YQoqxFYNItVo\nCEKxkcOQeCUi8u2nUiahX37D2sxXg0x5UCZiz/Qo6kLahLL9G0E/XGQ7Fa+NfAAM\no6Ei3EFIbTnLEjapbZ7simo8CjHC04oxSUI/klWcao89eKNM+11ohbSUqQKBgFiF\nbmu907Nh8YqWUjb19/vMcfKfpKyaCzdRN54NCPRZZnkUTtyZuqbXxdc3VgklfSC2\n3GVv71mGQ9p7mKF1H4Ly8d9DyrTb0wbZTMwobEXe2bbt6x6iZDe4MXKj7lUCYLUi\nuwr3HeYsKWAfZlJCsTMji8C1c344bZ2URe9oPldLAoGASaaChxQPnf2BMMq3Gb1/\nc/iHNdcCUDp0p+mUDRnwbDN60vM24KUYgD3dn0MaqeV5M6jBul+S/eGRFrfMBHi8\nyEoHlZ8S6zX2T7k6OxaOnx2UnkmECrkUJMWOXdejdIdGofwMNaG828G/qQ7I43q7\ncmUImG+wyr7XGKasK5EL8WU=\n-----END PRIVATE KEY-----\n",
      "client_email": "ridelanka@ridelanka-cb659.iam.gserviceaccount.com",
      "client_id": "103812347067352289477",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/ridelanka%40ridelanka-cb659.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final auth.AuthClient client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    String accessToken = client.credentials.accessToken.data;
    client.close();
    return accessToken;
  }

  static Future<void> sendNotificationsToUsers(
      String deviceToken, String title, String msg) async {
    final String serviceKey = await getAccessToken();

    String endPointUrl =
        "https://fcm.googleapis.com/v1/projects/ridelanka-cb659/messages:send";

    final Map<String, dynamic> notification = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": title,
          "body": msg,
          "image": "https://i.postimg.cc/phYxBcwn/van.png"
        },
        "data": {"tripId": deviceToken }
      }
    };

    final http.Response response = await http.post(Uri.parse(endPointUrl),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "Bearer $serviceKey"
        },
        body: jsonEncode(notification));

    if (response.statusCode == 200) {
      print("Notification sent!");
    } else {
      print("Notification failed: ${response.body}");
    }
  }
}
