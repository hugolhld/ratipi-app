import 'package:explore_fultter/components/ListAlert.dart';
import 'package:explore_fultter/components/StopView.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String? subtitle;

  const ListItem({
    required this.title,
    this.subtitle,
    super.key,
  });

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
        elevation: 4, // Ajoute une ombre sous la carte pour un effet 3D
        child: InkWell(
          borderRadius: BorderRadius.circular(
              15.0), // Assure que l'effet d'encre suit la forme arrondie
          onTap: () {
            if (subtitle != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StopView(stopTitle: subtitle!),
                ),
              );
            }
          },
          child: ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: subtitle != null ? Text(subtitle!) : null,
            leading: const Icon(Icons.directions_bus,
                color: Colors.teal), // Icône devant le texte
            trailing: Stack(
              clipBehavior:
                  Clip.none, // Permet d'afficher le badge en dehors du Stack
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
          ),
        ),
      ),
    );
  }
}
