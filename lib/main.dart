import 'package:explore_fultter/utils/local_notifications.dart';
import 'package:explore_fultter/utils/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:explore_fultter/utils/web_socket_manager.dart';
import 'package:explore_fultter/views/MyHomePage/MyHomePage.dart';
import 'package:explore_fultter/views/NotificationsPage/NotificationPage.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  LocalNotifications().initNotifications();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => NotificationProvider(),
      ),
    ],
    child: const MyApp(),
  ));
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
  List<String>? _favorites;

  static final List<Widget> _pages = <Widget>[
    const MyHomePage(),
    const NotificationPage(),
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

    _favorites = prefs.getStringList('favorites') ?? [];

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

  Future<bool> _checkIfFavorite(String route) async {
    return _favorites?.contains(route) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal[400],
          title: const Text('RATIPI',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  _pages[_selectedIndex],
                  Positioned.fill(
                    child: StreamBuilder<Map>(
                      stream: WebSocketManager().messageStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.active &&
                            snapshot.hasData) {
                          final data = snapshot.data!;
                          final stopData = data['stop'] ?? '';
                          final uuidData = data['uuid'] ?? '';
                          final alertData = data['alert'] ?? '';
                          final routeData = data['route'] ?? '';

                          return FutureBuilder<bool>(
                            future: _checkIfFavorite(routeData),
                            builder: (context, favoriteSnapshot) {
                              if (favoriteSnapshot.connectionState ==
                                      ConnectionState.done &&
                                  favoriteSnapshot.hasData) {
                                if (favoriteSnapshot.data == true) {
                                  LocalNotifications().showNotification(
                                    title: 'Alerte $alertData reçue',
                                    body:
                                        'Notification $alertData reçue: $stopData sur la ligne $routeData',
                                  );

                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Notification $alertData reçue: $stopData de $uuidData')),
                                    );
                                  });
                                }
                                return Container();
                              } else {
                                return Container();
                              }
                            },
                          );
                        }
                        return Container();
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
                selectedItemColor: Colors.teal,
                unselectedItemColor: Colors.teal.withOpacity(0.6),
                selectedLabelStyle: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  color: Colors.teal.withOpacity(0.6),
                ),
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
