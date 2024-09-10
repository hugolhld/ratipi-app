import 'package:explore_fultter/components/ListAlert.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  // final VoidCallback? onTap;

  const ListItem({
    required this.title,
    this.subtitle,
    // this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: () {
        // Open chat view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListAlert(title: title, routeId: subtitle),
          ),
        );
      },
    );
  }
}