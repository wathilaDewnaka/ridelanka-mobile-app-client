import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0051ED),
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
              title: const Text('Change Username'),
              trailing: const Icon(Icons.settings),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Change Email'),
              trailing: const Icon(Icons.settings),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Change Phone Number'),
              trailing: const Icon(Icons.settings),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
