import 'package:explore_fultter/components/StopView.dart';
import 'package:flutter/material.dart';

class ListAlert extends StatefulWidget {
  final String title;
  final String? routeId;

  const ListAlert({super.key, required this.title, this.routeId});

  @override
  _ListAlertState createState() => _ListAlertState();
}

class _ListAlertState extends State<ListAlert> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
            color: Colors.lightBlue[50],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.add),
                // Wrap the ListTile in an Expanded widget
                Expanded(
                  child: ListTile(
                    title: const Text('Ajouter une alerte !'),
                    onTap: () {
                      if (widget.routeId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StopView(stopTitle: widget.routeId!),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Route ID is missing!')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hello from Notif!',
              style: TextStyle(fontSize: 24),
            ),
            const Text(
              'Hello from Notif!',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
