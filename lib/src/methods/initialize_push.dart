import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class InitializePush {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  void initialize() async {
    firebaseMessaging.requestPermission();

    // Get and update the token initially
    String? token = await firebaseMessaging.getToken();
    if (token != null) {
      await updateTokenInDatabase(token);
    }

    // Listen for token refresh and update in DB
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM Token Refreshed: $newToken");
      await updateTokenInDatabase(newToken);
    });

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.body}');

      if (message.notification != null) {
        showNotification(message.notification!);
      }
    });

    // Listen for background notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Background message received: ${message.notification?.body}');
    });
  }

  Future<void> updateTokenInDatabase(String token) async {
    bool isPass = await HelperMethods.checkIsPassenger(firebaseUser!.uid);
    DatabaseReference ref = isPass
        ? FirebaseDatabase.instance.ref("users/${firebaseUser!.uid}/token")
        : FirebaseDatabase.instance.ref("drivers/${firebaseUser!.uid}/token");
    await ref.set(token);
  }

  Future<void> showNotification(RemoteNotification notification) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: notification.title,
        body: notification.body,
      ),
    );
  }
}
