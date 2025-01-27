import 'package:firebase_database/firebase_database.dart';

class HelperMethods {
  static Future<bool> checkPhoneNumberExists(
      String phoneNumber, bool isPassenger) async {
    final databaseReference = (isPassenger) ? FirebaseDatabase.instance.ref("users") :  FirebaseDatabase.instance.ref("drivers");

    try {
      final snapshot = await databaseReference
          .orderByChild("phone")
          .equalTo(phoneNumber)
          .get();

      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<bool> checkPhoneAndEmail(
      String phoneNumber, String email, bool isPassenger) async {
    final databaseReference = (isPassenger) ? FirebaseDatabase.instance.ref("users") :  FirebaseDatabase.instance.ref("drivers");

    try {
      final snapshot = await databaseReference
          .orderByChild("phone")
          .equalTo(phoneNumber)
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        bool emailMatches = false;

        data.forEach((key, value) {
          if (value['email'] == email) {
            emailMatches = true;
          }
        });
        return emailMatches;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }
}