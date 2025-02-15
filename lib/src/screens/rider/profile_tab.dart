import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF0051ED),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          Icon(
            Icons.person,
            size: 70,
          ),
          SizedBox(height: 20),
          Text(
            'Thisuri Nethma',
            style: TextStyle(fontSize: 16, letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              'My Details',
              style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15, bottom: 15),
            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'username',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
                Text(
                  'thisurinethma',
                  style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15, bottom: 15),
            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'e-mail',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
                Text(
                  'thisurinethma@gmailcom',
                  style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15, bottom: 15),
            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'phone number',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
                Text(
                  '+94 *********',
                  style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          SizedBox(height: 100),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings,
                    size: 26,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Manage Account',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: 26,
                  ),
                  SizedBox(width: 8),
                  Text('Log Out'),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
