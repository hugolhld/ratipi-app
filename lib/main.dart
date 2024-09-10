// import 'package:explore_fultter/views/MyHomePage/MyHomePage.dart';
import 'package:explore_fultter/views/MyHomePage/MyHomePage.dart';
import 'package:explore_fultter/views/NotificationsPage/NotificationPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // Index de la page actuellement sélectionnée

  // Liste des pages à afficher en fonction de la sélection
  static final List<Widget> _pages = <Widget>[
    const MyHomePage(),
    const Notificationpage(),
  ];

  // Fonction pour mettre à jour l'index sélectionné
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Future<void> _initializeUUID() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userId = prefs.getString('userId');

  //   if (userId == null) {
  //     // Generate a UUID if none exists
  //     userId = const Uuid().v4();
  //     // userId = Uuid().v4(); // Générer un UUID si aucun n'existe
  //     await prefs.setString('userId', userId);
  //   }
    
  //   // Naviguer vers la page principale de l'application
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(builder: (context) => const MyApp()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.tealAccent[400],
          title: const Text('Hello, World!'),
        ),
        body: _pages[_selectedIndex], // Affiche la page en fonction de l'index
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // Indique l'élément actuellement sélectionné
          onTap: _onItemTapped, // Déclenche l'événement lorsque l'utilisateur tape sur un élément
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}