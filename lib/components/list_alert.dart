import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratipi/utils/provider.dart';
import 'package:ratipi/components/stop_view.dart';
import 'package:intl/intl.dart';

class ListAlert extends StatefulWidget {
  final String title;
  final String routeId;
  final String mode;

  const ListAlert({super.key, required this.title, required this.routeId, required this.mode});

  @override
  _ListAlertState createState() => _ListAlertState();
}

class _ListAlertState extends State<ListAlert> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when the widget is initialized
    Provider.of<NotificationProvider>(context, listen: false)
        .fetchNotifications(widget.routeId);
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
              label: const Text('Ajouter une alerte !',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StopView(stopTitle: widget.routeId, mode: widget.mode,),
                    ),
                  );
              },
            ),

            const SizedBox(height: 15),
            // Texte stylisé "Alerte en cours"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alerte en cours',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  if (notificationProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (notificationProvider.hasError) {
                    return const Text('Error loading notifications');
                  } else if (notificationProvider
                      .getNotificationsForRoute(widget.routeId)
                      .isEmpty) {
                    return const Text('No notifications found');
                  } else {
                    return ListView.builder(
                      itemCount: notificationProvider
                          .getNotificationsForRoute(widget.routeId)
                          .length,
                      itemBuilder: (context, index) {
                        final item = notificationProvider
                            .getNotificationsForRoute(widget.routeId)[index];
                        final timestamp = item['timestamp'];
                        final DateTime notificationTime =
                            DateTime.fromMillisecondsSinceEpoch(timestamp);
                        final Duration timeDifference =
                            DateTime.now().difference(notificationTime);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                            child: ExpansionTile(
                              title: Text(item['stop'] ?? 'Unnamed Stop'),
                              subtitle: Text(
                                  'Il y a ${timeDifference.inMinutes} minutes'),
                              leading: const Icon(Icons.notification_important,
                                  color: Colors.teal),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.warning,
                                              color: Colors.red),
                                          SizedBox(
                                              width:
                                                  8), // Espace entre l'icône et le texte
                                          Text(
                                            'Attention !',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight
                                                  .bold, // Texte en gras
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              8), // Espace entre le texte et l'heure
                                      const Text(
                                        'Des contrôleurs ont été signalés à cet arrêt.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Heure signalée : ${DateFormat('HH:mm').format(notificationTime)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
