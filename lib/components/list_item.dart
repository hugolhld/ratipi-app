import 'package:explore_fultter/components/list_alert.dart';
import 'package:explore_fultter/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final String mode;

  const ListItem({
    required this.title,
    required this.mode,
    required this.subtitle,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfFavorite();
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications(widget.subtitle!);
    });
  }

  Future<void> _checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      isFavorite = favorites.contains(widget.subtitle);
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];

    String? favoriteItem = widget.subtitle;

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListAlert(
                    title: widget.title,
                    routeId: widget.subtitle,
                    mode: widget.mode),
              ),
            );
          },
          child: ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            // subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
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
                      child: Consumer<NotificationProvider>(
                        builder: (context, provider, child) {
                          return provider
                                  .getNotificationsForRoute(widget.subtitle)
                                  .isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      provider
                                          .getNotificationsForRoute(
                                              widget.subtitle)
                                          .length
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
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
