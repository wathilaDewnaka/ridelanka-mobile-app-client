import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              trailing: const Icon(Icons.keyboard_arrow_down, color: iconColor),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: iconBackgroundColor,
                child: Icon(Icons.email_outlined, color: iconColor),
              ),
              title: const Text('Change Email'),
              trailing: const Icon(Icons.keyboard_arrow_down, color: iconColor),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
