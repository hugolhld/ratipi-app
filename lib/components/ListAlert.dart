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
            const SizedBox(height: 20), // Espace au-dessus du bouton
            ElevatedButton.icon(
              icon: const Icon(Icons.add,
                  color: Colors.white), // Icône avant le texte
              label: const Text(
                'Ajouter une alerte !',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Couleur de fond du bouton
                foregroundColor: Colors.white, // Couleur de l'icône et du texte
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Coins arrondis
                ),
                elevation: 2, // Ombre du bouton pour un effet 3D
              ),
              onPressed: () {
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
                        return ListTile(
                          title: Text(item?['stop'] ?? 'Unnamed Stop'),
                          subtitle: Text(item?['uuid'] ?? 'No ID'),
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
