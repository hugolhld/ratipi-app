import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_fultter/utils/firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:explore_fultter/utils/web_socket_manager.dart';
import 'package:explore_fultter/views/MyHomePage/MyHomePage.dart';
import 'package:explore_fultter/views/NotificationsPage/NotificationPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirestoreService firestoreService = FirestoreService();
  // QuerySnapshot dbData = (await firestoreService.getDocuments('/notifications')) as QuerySnapshot<Object?>;
  // List<QueryDocumentSnapshot> docs = dbData.docs;
  // if (docs.isNotEmpty) {
  //   print(docs.first.data());
  // }

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
  bool _isLoading = true;

  static final List<Widget> _pages = <Widget>[
    const MyHomePage(),
    const Notificationpage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeUUID();
    WebSocketManager().connect();
  }

  Future<void> _initializeUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('userId', userId);
    }

    setState(() {
      _userId = userId;
      _isLoading = false;
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
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  _pages[_selectedIndex],
                  // StreamBuilder for WebSocket messages
                  Positioned.fill(
                    child: StreamBuilder<Map>(
                      stream: WebSocketManager().messageStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          String stopData = snapshot.data!['stop'];
                          String uuidData = snapshot.data!['uuid'];
                          String alertData = snapshot.data!['alert'];

                          // if(uuidData == _userId) {
                          //   return Container(); // Return an empty container
                          // }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Notification $alertData reçue: $stopData de $uuidData')),
                            );
                          });
                        }

                        return Container(); // Return an empty container
                      },
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: _isLoading
            ? null
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
