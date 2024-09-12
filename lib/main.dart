import 'dart:async';
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  String? _userId;
  bool _isLoading = true;
  List<String>? _favorites;
  late WebSocketManager _webSocketManager;
  late StreamSubscription<Map> _webSocketSubscription;

  static final List<Widget> _pages = <Widget>[
    const MyHomePage(),
    const NotificationPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _webSocketManager = WebSocketManager();
    _initializeUUID();
    // Connect to WebSocket after initialization is complete
    Future.microtask(() {
      _connectToWebSocket();
    });
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

  void _connectToWebSocket() {
    // Ensure WebSocketManager is initialized before connecting
    if (!_webSocketManager.isConnected) {
      _webSocketSubscription = _webSocketManager.messageStream.listen((message) {
        _handleWebSocketMessage(message);
      });
      _webSocketManager.connect();
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) async {
    final stopData = message['stop'] ?? '';
    final uuidData = message['uuid'] ?? '';
    final alertData = message['alert'] ?? '';
    final routeData = message['route'] ?? '';

    final isFavorite = await _checkIfFavorite(routeData);
    if (isFavorite) {
      LocalNotifications().showNotification(
        title: 'Alerte $alertData reçue',
        body: 'Notification $alertData reçue: $stopData sur la ligne $routeData',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification $alertData reçue: $stopData de $uuidData')),
        );
      });
    }
  }

  Future<bool> _checkIfFavorite(String route) async {
    return _favorites?.contains(route) ?? false;
  }

  void _disconnectFromWebSocket() {
    _webSocketSubscription.cancel();
    _webSocketManager.disconnect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print('App paused');
      _disconnectFromWebSocket();
    } else if (state == AppLifecycleState.resumed) {
      print('App resumed');
      if (!_webSocketManager.isConnected) {
        _connectToWebSocket();
      }
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      _disconnectFromWebSocket();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disconnectFromWebSocket();
    super.dispose();
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
                ],
              ),
        bottomNavigationBar: _isLoading
            ? null
            : BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
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

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    throw UnimplementedError();
  }

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}
}
