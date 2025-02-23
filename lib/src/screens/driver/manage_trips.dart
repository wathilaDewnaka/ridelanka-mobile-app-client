import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RidesTab extends StatefulWidget {
  @override
  State<RidesTab> createState() => _RidesTabState();
}

class _RidesTabState extends State<RidesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Welcome to rides Screen",
          style: TextStyle(fontSize: 24), // Optional: adjust text size
        ),
      ),
    );
  }
}
