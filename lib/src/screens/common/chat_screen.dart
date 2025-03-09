import 'package:client/src/methods/encrypt_methods.dart';
import 'package:client/src/methods/push_notification_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key,
      required this.recieverName,
      required this.recieverUid,
      required this.recieverTel,
      required this.isMobile,
      required this.senderId});

  final String recieverName;
  final String recieverUid;
  final String recieverTel;
  final String senderId;
  final bool isMobile;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  late String receiverId;
  late String receiverName;
  late String senderId;

  @override
  void initState() {
    super.initState();
    receiverId = widget.recieverUid;
    receiverName = widget.recieverName;
    senderId = widget.senderId;
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

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final messageData = {
        'text': EncryptMethods.encryptText(_messageController.text),
        'sender': EncryptMethods.encryptText(senderId),
        'receiver': EncryptMethods.encryptText(receiverId),
        'timestamp': ServerValue.timestamp,
      };

      _dbRef.child('messages').push().set(messageData);
      _messageController.clear();

      // try {
      //   DatabaseReference fcm = senderId.split(" ")[0] == "drivers"
      //       ? FirebaseDatabase.instance
      //           .ref()
      //           .child("users/${widget.recieverUid}/token")
      //       : FirebaseDatabase.instance
      //           .ref()
      //           .child("drivers/${widget.recieverUid}/token");

      //   DataSnapshot snapshot = await fcm.get();
      //   String token = snapshot.value as String;
      //   PushNotificationService.sendNotificationsToUsers(token,
      //       "New chat ", "User is absenting check details");
      // } catch (e) {
      //   print(e);
      // }
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
            if (widget.isMobile)
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
                  return const Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("No messages yet. Start a conversation!"));
                }

                Map<dynamic, dynamic> messagesMap =
                    data as Map<dynamic, dynamic>;

                List<Map<String, dynamic>> messages = messagesMap.entries
                    .map((entry) => {
                          'text':
                              EncryptMethods.decryptText(entry.value['text']),
                          'sender':
                              EncryptMethods.decryptText(entry.value['sender']),
                          'receiver': EncryptMethods.decryptText(
                              entry.value['receiver']),
                          'timestamp': entry.value['timestamp'] ?? 0,
                        })
                    .toList();

                messages = messages.where((message) {
                  return (message['sender'] == senderId &&
                          message['receiver'] == receiverId) ||
                      (message['sender'] == receiverId &&
                          message['receiver'] == senderId);
                }).toList();

                messages
                    .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                // If no messages match the criteria
                if (messages.isEmpty) {
                  return const Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("No messages yet. Start a conversation!"));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['sender'] == senderId;

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
