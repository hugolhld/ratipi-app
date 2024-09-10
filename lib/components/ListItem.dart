import 'package:explore_fultter/components/ListAlert.dart';
import 'package:explore_fultter/components/StopView.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0), // Ajoute de l'espace autour des cartes
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15.0), // Coins arrondis de la carte
        ),
        elevation: 2, // Ajoute une ombre sous la carte pour un effet 3D
        child: InkWell(
          borderRadius: BorderRadius.circular(
              10), // Assure que l'effet d'encre suit la forme arrondie
          onTap: () {
            if (widget.subtitle != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ListAlert(title: widget.title, routeId: widget.subtitle),
                ),
              );
            }
          },
          child: ListTile(
            title: Text(
              widget.title,
            ),
            subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
            leading: const Icon(Icons.directions_bus,
                color: Colors.teal), // Icône devant le texte
            trailing: Row(
              mainAxisSize:
                  MainAxisSize.min, // Minimise l'espace utilisé par le Row
              children: [
                Stack(
                  clipBehavior: Clip
                      .none, // Permet d'afficher le badge en dehors du Stack
                  children: [
                    const Icon(Icons.notifications,
                        color: Colors.teal), // Icône de notification
                    Positioned(
                      right: -8, // Décale le badge à droite de l'icône
                      top: -8, // Décale le badge vers le haut
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: const Text(
                          '3', // Nombre de notifications (peut être dynamique)
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8), // Espace entre les deux icônes
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







// ListTile(
    //   title: Text(widget.title),
    //   subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
    //   trailing: IconButton(
    //     color: Colors.red,
    //     onPressed: _toggleFavorite,
    //     icon: Icon(
    //       isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
    //     ),
    //   ),
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) =>
    //             ListAlert(title: widget.title, routeId: widget.subtitle),
    //       ),
    //     );
    //   },
    // );