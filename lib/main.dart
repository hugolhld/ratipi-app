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
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  String? _userId;
  bool _isLoading = true; // To track if the UUID is being initialized

  static final List<Widget> _pages = <Widget>[
    const MyHomePage(),
    const Notificationpage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeUUID(); // Call the initialization function
  }

  Future<void> _initializeUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      userId = const Uuid().v4(); // Generate a new UUID if none exists
      await prefs.setString('userId', userId);
    }

    setState(() {
      _userId = userId;
      _isLoading = false; // UUID has been initialized, hide loading screen
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.tealAccent[400],
          title: const Text('Hello, World!'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator()) // Show a loading indicator while UUID is being initialized
            : _pages[_selectedIndex], // Show main content when UUID is ready
        bottomNavigationBar: _isLoading
            ? null // Hide the bottom navigation while loading
            : BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
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