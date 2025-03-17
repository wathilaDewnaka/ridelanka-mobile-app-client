import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/screens/auth/mobile_login_screen.dart';
import 'package:client/src/screens/driver/driver_dashboard.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isUsernameExpanded = false;
  bool showEmailField = false;

  String? title = "Mr.";
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String online = prefs.getString("online") ?? "false";
      if (online == "true") {
        ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
            title: "Error",
            message: "End the trip to delete",
            type: MessageType.error));
        return;
      }

      bool isPassenger =
          await HelperMethods.checkIsPassenger(firebaseUser!.uid);

      DatabaseReference databaseReference = isPassenger
          ? FirebaseDatabase.instance.ref().child('users/${firebaseUser!.uid}')
          : FirebaseDatabase.instance
              .ref()
              .child('drivers/${firebaseUser!.uid}');

      await databaseReference.remove();

      final FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.signOut();
      await prefs.clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MobileLoginScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Account Deleted",
        message: "Your account has been successfully deleted.",
        type: MessageType.success,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message: "Failed to delete account. Please try again.",
        type: MessageType.error,
      ));
    }
  }

  void _updateUsername(String fullname) async {
    if (fullname.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
          title: "Error",
          message: "Please enter a valid name!",
          type: MessageType.error));
      return;
    } else if (fullname.split(" ").length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
          title: "Error",
          message: "Please enter a valid name!",
          type: MessageType.error));
      return;
    }

    bool isPassenger = await HelperMethods.checkIsPassenger(firebaseUser!.uid);
    DatabaseReference databaseReference = isPassenger
        ? FirebaseDatabase.instance.ref("users/${firebaseUser!.uid}")
        : FirebaseDatabase.instance.ref("drivers/${firebaseUser!.uid}");

    String fullnameAll =
        "${title!} ${capitalize(fullname.split(" ")[0])} ${capitalize(fullname.split(" ")[1])}";

    await databaseReference.update({"fullname": fullnameAll});

    if (!isPassenger) {
      driverName = fullnameAll;
    }

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => isPassenger
                ? const RiderNavigationMenu(selectedIndex: 3)
                : const DriverHome()),
        (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: "Name updated successfully !",
        type: MessageType.success));
  }

  void _updateEmail(String email) async {
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
          title: "Error",
          message: "Invalid email address!",
          type: MessageType.error));
      return;
    }

    bool isPassenger = await HelperMethods.checkIsPassenger(firebaseUser!.uid);
    DatabaseReference databaseReference = isPassenger
        ? FirebaseDatabase.instance.ref("users/${firebaseUser!.uid}")
        : FirebaseDatabase.instance.ref("drivers/${firebaseUser!.uid}");

    await databaseReference.update({"email": email});

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => isPassenger
                ? const RiderNavigationMenu(selectedIndex: 3)
                : const DriverHome()),
        (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: "Email updated successfully !",
        type: MessageType.success));
  }

  Future<void> _logout(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth.signOut();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String online = prefs.getString("online") ?? "false";

    if (online == "true") {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
          title: "Error",
          message: "End the trip to logout",
          type: MessageType.error));
      return;
    }

    await prefs.clear(); // Removes all stored preferences
    await FirebaseMessaging.instance.deleteToken();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MobileLoginScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: "User logged out successfully !",
        type: MessageType.success));
    return;
  }

  @override
  Widget build(BuildContext context) {
    const Color iconColor = Color(0xFF0051ED);
    const Color iconBackgroundColor = Color(0x1A0051ED);

    return Scaffold(
      backgroundColor: iconColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF0051ED),
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 17.0),
              child: Text(
                "Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: iconBackgroundColor,
                  child: Icon(Icons.person_outline, color: iconColor),
                ),
                title: const Text('Change Username'),
                trailing: Icon(
                  isUsernameExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: iconColor,
                ),
                onTap: () {
                  setState(() {
                    isUsernameExpanded = !isUsernameExpanded;
                  });
                },
              ),
              if (isUsernameExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                border: Border.all(
                                    color: Colors.grey), // Border for
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: DropdownButton<String>(
                                value: title,
                                items: ["Mr.", "Mrs.", "Miss", "Dr.", "Prof."]
                                    .map((String value) =>
                                        DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    title = value;
                                  });
                                },
                                underline:
                                    const SizedBox(), // Remove default underline
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: "Full Name",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity, // Full width
                        height: 55, // Fixed height
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _updateUsername(nameController.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0051ED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.save_as,
                              color: Colors.white, size: 26),
                          label: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: iconBackgroundColor,
                  child: Icon(Icons.email_outlined, color: iconColor),
                ),
                title: const Text('Change Email'),
                trailing: Icon(
                  showEmailField
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: iconColor,
                ),
                onTap: () {
                  setState(() {
                    showEmailField = !showEmailField;
                  });
                },
              ),
              if (showEmailField)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Enter new email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity, // Full width
                        height: 55, // Fixed height
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _updateEmail(emailController.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0051ED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.save_as,
                              color: Colors.white, size: 26),
                          label: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              const SizedBox(height: 30),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _logout(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 70, vertical: 12),
                            decoration: BoxDecoration(
                              color: iconColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout,
                                    size: 26, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _confirmDeleteAccount();
                          },
                          child: const Text(
                            'Delete Account',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
