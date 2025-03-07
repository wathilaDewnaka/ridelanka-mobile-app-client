import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/screens/common/chat_screen_ai.dart';
import 'package:client/src/screens/common/settings_tab.dart';
import 'package:client/src/screens/auth/mobile_login_screen.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late String fullName = "Mr. NaN NaN";
  late String email = "";
  late String phone = "";
  bool isLoading = true; // Control UI visibility

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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MobileLoginScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: "User logged out successfully !",
        type: MessageType.success));
    return;
  }

  Future<void> getUserDetails() async {
    bool isPassenger = await HelperMethods.checkIsPassenger(firebaseUser!.uid);

    DatabaseReference databaseReference = isPassenger
        ? FirebaseDatabase.instance.ref("users/${firebaseUser!.uid}")
        : FirebaseDatabase.instance.ref("drivers/${firebaseUser!.uid}");

    DatabaseEvent event = await databaseReference.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(snapshot.value as Map);

      setState(() {
        email = userData['email'] ?? '';
        fullName = userData['fullname'] ?? '';
        phone = userData['phone'] ?? '';
        isLoading = false; // Stop loading once data is fetched
      });
    } else {
      print("User data not found");
      setState(() {
        isLoading = false; // Stop loading even if no data is found
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Please wait...'),
      );

      // Initialize async tasks
      getUserDetails().then((_) {
        // After tasks are complete, dismiss the dialog
        print("object");
        Navigator.pop(context);
      }).catchError((error) {
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF0051ED),
        title: isLoading
            ? null // Show nothing while loading
            : Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(17),
                      child: Center(
                        child: Text(
                          fullName.split(" ")[1][0],
                          style: TextStyle(
                            fontSize: 55,
                            color: Color(0xFF0051ED),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          fullName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        toolbarHeight: 130,
      ),
      body: isLoading
          ? Container()
          : ListView(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Account Information',
                    style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                _buildInfoTile(Icons.person, 'Username',
                    "${fullName.split(" ")[1]} ${fullName.split(" ")[2]}"),
                _buildInfoTile(Icons.email, 'Email', email),
                _buildInfoTile(Icons.phone, 'Phone Number', phone),
                GestureDetector(
                  child: _buildInfoTile(Icons.chat, "Chat", "Chat with our AI"),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatScreenAI())),
                ),
                const SizedBox(height: 10),
                _buildSettingsAndLogoutButtons(),
              ],
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 13, bottom: 18, top: 18),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF99C2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              icon,
              color: Color(0xFF0051ED),
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toLowerCase(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsAndLogoutButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0051ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(Icons.settings, color: Colors.white, size: 26),
                  label: Text(
                    'Settings',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            _logout(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF0051ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 26,
                          color: Colors.white,
                        ),
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
              ],
            ),
          ),
        )
      ],
    );
  }
}
