import 'package:ratipi/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class InitializeUUIDPage extends StatefulWidget {
  const InitializeUUIDPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InitializeUUIDPageState createState() => _InitializeUUIDPageState();
}

class _InitializeUUIDPageState extends State<InitializeUUIDPage> {
  @override
  void initState() {
    super.initState();
    _initializeUUID();
  }

  Future<void> _initializeUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    
    if (userId == null) {
      // Generate a UUID if none exists
      userId = const Uuid().v4();
      // userId = Uuid().v4(); // Générer un UUID si aucun n'existe
      await prefs.setString('userId', userId);
    }
    
    // Naviguer vers la page principale de l'application
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initializing...')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
