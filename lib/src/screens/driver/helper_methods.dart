import 'package:firebase_database/firebase_database.dart';

class HelperMethods {
  static Future<String?> getDriverName(String uid) async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("drivers/$uid/fullname");

      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        return snapshot.value as String;
      } else {
        print("Driver fullname not found at drivers/$uid/fullname.");
        return null;
      }
    } catch (e) {
      print("Error fetching driver name: $e");
      return null;
    }
  }
}
