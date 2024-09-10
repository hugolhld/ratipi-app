import 'package:explore_fultter/components/ListAlert.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      isFavorite = favorites.contains(widget.title);
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];

    String favoriteItem = widget.title;

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
    return ListTile(
      title: Text(widget.title),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
      trailing: IconButton(
        color: Colors.red,
        onPressed: _toggleFavorite,
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ListAlert(title: widget.title, routeId: widget.subtitle),
          ),
        );
      },
    );
  }
}
