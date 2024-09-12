import 'package:explore_fultter/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchAllNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return const Center(child: Text('Error fetching notifications'));
          }

          final notifications = provider.allNotifications;
          // Sort notifications by timestamp
          notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications available.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              // Check how mmuch time has passed since the notification was created fromMillisecondsSinceEpoch
              final timePassed = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(notification['timestamp']));
              final timePassedString = timePassed.inMinutes > 0
                  ? '${timePassed.inMinutes} minute${timePassed.inMinutes > 1 ? 's' : ''}'
                  : 'moins d\'une minute';
                
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_rounded,
                        color: Colors.red), // Icône d'alerte
                    title: Text("Ligne ${notification['route']} à l'arrêt ${notification['stop']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Texte en gras
                        )),
                    subtitle: Text('Il y a $timePassedString'),
                    // trailing: const Icon(Icons.arrow_forward_ios), // Icône à droite
                    // onTap: () {
                    //   // Action lorsqu'on appuie sur une notification
                    // },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
