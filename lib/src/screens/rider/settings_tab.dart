import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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

  void _updateUsername(String fullname) async {
    bool isPassenger = await HelperMethods.checkIsPassenger(firebaseUser!.uid);
    DatabaseReference databaseReference = isPassenger
        ? FirebaseDatabase.instance.ref("users/${firebaseUser!.uid}")
        : FirebaseDatabase.instance.ref("drivers/${firebaseUser!.uid}");

    await databaseReference.update({"fullname": fullname});

    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: "Name updated successfully !",
        type: MessageType.success));
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
                leading: CircleAvatar(
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
                                  horizontal: 8, vertical: 2),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0051ED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(Icons.save_as,
                              color: Colors.white, size: 26),
                          label: Text(
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
                leading: CircleAvatar(
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
                        decoration: InputDecoration(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0051ED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(Icons.save_as,
                              color: Colors.white, size: 26),
                          label: Text(
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
                              Icon(Icons.logout, size: 26, color: Colors.white),
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
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
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
