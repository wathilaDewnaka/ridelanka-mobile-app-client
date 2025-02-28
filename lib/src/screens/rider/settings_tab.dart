import 'package:client/src/widgets/message_bar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isUsernameExpanded = false;
  bool showEmailField = false;

  @override
  Widget build(BuildContext context) {
    const Color iconColor = Color(0xFF0051ED);
    const Color iconBackgroundColor = Color(0x1A0051ED);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: iconColor,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter new username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            createMessageBar(
                                title: "Error",
                                message: "Inavlid username",
                                type: MessageType.error));
                      },
                      child: const Text('Save'),
                    ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter new email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            createMessageBar(
                                title: "Error",
                                message: "Inavlid email address",
                                type: MessageType.error));
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 200),
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
    );
  }
}
