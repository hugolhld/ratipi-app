import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:explore_fultter/utils/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_fultter/components/StopView.dart';

class ListAlert extends StatefulWidget {
  final String title;
  final String? routeId;

  const ListAlert({super.key, required this.title, this.routeId});

  @override
  _ListAlertState createState() => _ListAlertState();
}

class _ListAlertState extends State<ListAlert> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when the widget is initialized
    if (widget.routeId != null) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications(widget.routeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ajouter une alerte !', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              onPressed: () {
                if (widget.routeId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StopView(stopTitle: widget.routeId!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Route ID is missing!')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              // Utiliser Consumer pour écouter les changements dans NotificationProvider
              child: Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  if (notificationProvider.isLoading) {
                    return const CircularProgressIndicator();
                  } else if (notificationProvider.hasError) {
                    return const Text('Error loading notifications');
                  } else if (notificationProvider.notifications.isEmpty) {
                    return const Text('No notifications found');
                  } else {
                    return ListView.builder(
                      itemCount: notificationProvider.notifications.length,
                      itemBuilder: (context, index) {
                        final item = notificationProvider.notifications[index];
                        final timestamp = item['timestamp'];
                        final DateTime notificationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                        final Duration timeDifference = DateTime.now().difference(notificationTime);

                        return ListTile(
                          title: Text(item['stop'] ?? 'Unnamed Stop'),
                          subtitle: Text('Il y a ${timeDifference.inMinutes} minutes'),
                          onTap: () {
                            // Handle tap on the notification
                          },
                        );
                      },
                    );
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