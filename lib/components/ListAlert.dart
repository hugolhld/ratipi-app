import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_fultter/components/StopView.dart';
import 'package:explore_fultter/utils/firebase.dart';
import 'package:flutter/material.dart';

class ListAlert extends StatefulWidget {
  final String title;
  final String? routeId;

  const ListAlert({super.key, required this.title, this.routeId});

  @override
  _ListAlertState createState() => _ListAlertState();
}

class _ListAlertState extends State<ListAlert> {
  // Use getNotificationsByStop to get notifications
  Future<List<QueryDocumentSnapshot<Object?>>?> getNotifications() async {
    try {
      final QuerySnapshot notifications = await FirestoreService().getNotificationsByStop(widget.routeId!);
      print(notifications.docs);
      return notifications.docs;
    } catch (e) {
      print('Error getting notifications: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              color: Colors.lightBlue[50],
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.add),
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
            Expanded(
              // Wrapping FutureBuilder with Expanded so the ListView doesn't overflow
              child: FutureBuilder<List<QueryDocumentSnapshot<Object?>>?>(
                future: getNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading notifications');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    print(snapshot.data?.length);
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = snapshot.data?[index];
                        final timestamp = item?['timestamp'];
                        final DateTime notificationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                        final Duration timeDifference = DateTime.now().difference(notificationTime);
                        return ListTile(
                          title: Text(item?['stop'] ?? 'Unnamed Stop'),
                          subtitle: Text('Il y a ${timeDifference.inMinutes} minutes'),
                          onTap: () {
                            // Handle tap on the notification
                          },
                        );
                      },
                    );
                  } else {
                    return const Text('No notifications found');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
