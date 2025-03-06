import 'dart:convert';

import 'package:client/global_variable.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreenAI extends StatefulWidget {
  const ChatScreenAI({
    super.key,
  });

  @override
  _ChatScreenAIState createState() => _ChatScreenAIState();
}

class _ChatScreenAIState extends State<ChatScreenAI> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> myList = [];

  Future<void> makePostRequest(String message) async {
    final url =
        Uri.parse('https://harmonious-dream-production.up.railway.app/chat');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'message': message}),
    );

    setState(() {
      myList.add({
        'text': message,
        'sender': firebaseUser!.uid,
        'receiver': "AI",
        'timestamp': ServerValue.timestamp,
      });
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      setState(() {
        myList.add({
          'text': responseData["response"],
          'sender': "AI",
          'receiver': firebaseUser!.uid,
          'timestamp': ServerValue.timestamp,
        });
      });
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  void sendMessage() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );
    
    if (_messageController.text.isNotEmpty) {
      await makePostRequest(_messageController.text);
    }

    _messageController.clear();
    Navigator.pop(context);
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
              "RideLanka AI",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: myList.length,
              itemBuilder: (context, index) {
                var message = myList[index];
                bool isMe = message['sender'] == firebaseUser!.uid;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF0051ED) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text'],
                      style:
                          TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (myList.isEmpty)
            const Align(
                alignment: Alignment.bottomCenter,
                child: Text("Start a conversation with our AI !")),
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
