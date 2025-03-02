import 'package:flutter/material.dart';

class Confirmsheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  Confirmsheet({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: Offset(0.7, 0.7)),
      ]),
      height: 220,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Brand-Bold',
                  color: Color(0xFF383635)),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF918D8D)),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                        Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Color(0xFF383635),
                      side: BorderSide(color: Color(0xFF383635)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      shadowColor: Colors.transparent
                    ),
                    child: Text(
                      "BACK",
                      style: TextStyle(color: Color(0xFF383635), fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (title=='START TRIP') ? Color(0xFF40cf89) : Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "CONFIRM",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
