import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  final String title;
  final String? subtitle;

  const ChatView({super.key, required this.title, this.subtitle});

  @override
  _ChatViewState createState() => _ChatViewState();
}

  class _ChatViewState extends State<ChatView> {
    List<String> messages = [/* 'Hello, World!' */];
    final TextEditingController _controller = TextEditingController();

    void sendMessage() {
      String message = _controller.text;
      if (message.isNotEmpty) {
        setState(() {
          messages.add(message);
          _controller.clear();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // Create a body with a div for messages and a div for the input field at the bottom
      body: Column(
        children: [
          // Add a ListView to display messages
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) { 
                return ListTile(
                  title: Text(messages[index]),
                );
               },
            ),
          ),
          // Add a TextField to the bottom of the screen for entering messages
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Enter message"),
                  ),
                ),
                IconButton(
                  alignment: Alignment.center,
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                    // webSocketProvider.sendMessage(_controller.text);
                    // _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
