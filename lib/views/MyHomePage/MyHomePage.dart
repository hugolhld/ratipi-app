import 'package:flutter/material.dart';
import 'package:explore_fultter/components/ListItem.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hello, World!'),
                Text('data'),
                Text('cc'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (int i = 1; i <= 14; i++)
                  ListItem(title: 'Ligne $i', subtitle: '$i'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
