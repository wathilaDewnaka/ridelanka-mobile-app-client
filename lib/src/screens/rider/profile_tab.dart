import 'package:client/src/screens/auth/mobile_login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _logout(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("isPassenger"); // Removes the value associated with the given key
    // Navigate to the login page or perform other actions after logout
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MobileLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            _logout(context);
          },
          child: Text("Logout")),
    );
  }
}
