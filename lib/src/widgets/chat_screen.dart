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
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
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
          Expanded(
            child: StreamBuilder(
              stream:
                  _dbRef.child('messages').orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!.snapshot.value;
                if (data == null) {
                  return const Center(
                      child: Text("No messages yet. Start a conversation!"));
                }

                Map<dynamic, dynamic> messagesMap =
                    data as Map<dynamic, dynamic>;

                List<Map<String, dynamic>> messages = messagesMap.entries
                    .map((entry) => {
                          'text': entry.value['text'],
                          'sender': entry.value['sender'],
                          'receiver': entry.value['receiver'],
                          'timestamp': entry.value['timestamp'] ?? 0,
                        })
                    .where((message) =>
                        (message['sender'] == firebaseUser!.uid &&
                            message['receiver'] == receiverId))
                    .toList();

                messages
                    .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                // If no messages match the criteria
                if (messages.isEmpty) {
                  return const Center(
                      child: Text("No messages found.! Start a conversation"));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['sender'] == firebaseUser!.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              isMe ? const Color(0xFF0051ED) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
