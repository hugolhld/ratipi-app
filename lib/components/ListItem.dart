import 'package:explore_fultter/components/ListAlert.dart';
import 'package:explore_fultter/utils/firebase.dart';
import 'package:explore_fultter/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListItem extends StatefulWidget {
  final String title;
  final String? subtitle;

  const ListItem({
    required this.title,
    this.subtitle,
    super.key,
  });

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  bool isFavorite = false;
  String notificationsCount = '0';

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _getNotificationsCount();
  }

  Future<void> _checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      isFavorite =
          widget.subtitle != null && favorites.contains(widget.subtitle);
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];

    String? favoriteItem = widget.subtitle;

    if (favoriteItem != null) {
      setState(() {
        if (favorites.contains(favoriteItem)) {
          favorites.remove(favoriteItem);
          isFavorite = false;
        } else {
          favorites.add(favoriteItem);
          isFavorite = true;
        }
      });

      await prefs.setStringList('favorites', favorites);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite
              ? '${widget.title} ajouté aux favoris.'
              : '${widget.title} retiré des favoris.'),
        ),
      );
    }
  }

  Future<void> _getNotificationsCount() async {
    if (widget.subtitle != null) {
      FirestoreService firestoreService = FirestoreService();
      int count =
          await firestoreService.getNotificationsCountByRoute(widget.subtitle!);

      setState(() {
        notificationsCount = count.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (widget.subtitle != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ListAlert(title: widget.title, routeId: widget.subtitle!),
                ),
              );
            }
          },
          child: ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
            leading: const Icon(Icons.directions_bus, color: Colors.teal),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications, color: Colors.teal),
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: notificationsCount != '0'
                            ? BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        // child: Center(
                        //   child: Consumer<NotificationProvider>(
                        //     builder: (context, notificationsCount, child) {
                        //       return Text(
                        //         notificationsCount.getCountByRoute(widget.subtitle!) as String,
                        //         style: const TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 12,
                        //         ),
                        //       );
                        //     },
                            
                        //   )
                        // ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  color: Colors.red,
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
