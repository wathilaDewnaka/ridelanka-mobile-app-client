import 'package:client/global_variable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key,
      required this.recieverName,
      required this.recieverUid,
      required this.recieverTel});

  final String recieverName;
  final String recieverUid;
  final String recieverTel;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  late String receiverId;
  late String receiverName;
  int countMsg = 0;

  @override
  void initState() {
    super.initState();
    receiverId = widget.recieverUid;
    receiverName = widget.recieverName;
  }

  void _makePhoneCall() async {
    String phoneNumber = widget.recieverTel;

    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final messageData = {
        'text': _messageController.text,
        'sender': firebaseUser!.uid,
        'receiver': receiverId,
        'timestamp': ServerValue.timestamp,
      };

      _dbRef.child('messages').push().set(messageData);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white, size: 24), // Small back button
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: const Color(0xFF0051ED),
        title: Row(
          children: [
            Text(
              receiverName,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Spacer(),
            IconButton(
                onPressed: _makePhoneCall,
                icon: const Icon(Icons.call, color: Colors.white))
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Enter message",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0051ED),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
