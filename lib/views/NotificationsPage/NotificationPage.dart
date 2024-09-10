import 'package:flutter/material.dart';

class Notificationpage extends StatelessWidget {
  const Notificationpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notif Page'),
      ),
      body: const Center(
        child: Text(
          'Hello from Notif!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
