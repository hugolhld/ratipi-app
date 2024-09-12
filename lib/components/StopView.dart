import 'dart:convert';
import 'package:explore_fultter/utils/firebase.dart';
import 'package:explore_fultter/utils/web_socket_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StopView extends StatefulWidget {
  final String stopTitle;

  const StopView({
    required this.stopTitle,
    super.key,
  });

  @override
  _StopViewState createState() => _StopViewState();
}

class _StopViewState extends State<StopView> {
  List<Map<String, dynamic>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/arrets-lignes.json');
      final List<dynamic> data = json.decode(response);

      final List<Map<String, dynamic>> filteredData = data
          .map((item) => item['fields'] as Map<String, dynamic>)
          .where((fields) => fields['mode'] == 'Metro' && fields['route_long_name'] == widget.stopTitle)
          .toList();

      setState(() {
        _filteredData = filteredData;
      });

      print(filteredData);
    } catch (e) {
      print('Error loading asset: $e');
    }
  }

  Future<void> _showAlert(String message, String stop) async {
    // Get UUID
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uuid = prefs.getString('userId');
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vous avez vu les controlleurs à la station $stop ?'),
          // content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                FirestoreService firestoreService = FirestoreService();
                firestoreService.addDocument('notifications', {
                  'alert': 'controlleurs',
                  'route': widget.stopTitle,
                  'stop': stop,
                  'uuid': uuid,
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                });

                WebSocketManager().sendMessage({
                  'alert': 'controlleurs',
                  'route': widget.stopTitle,
                  'stop': stop,
                  'uuid': uuid,
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                } as Map<String, dynamic>);

                Navigator.pop(context);
              },
              child: const Text('Ajouter une alerte'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stops for ${widget.stopTitle}'),
      ),
      // padding: const EdgeInsets.all(8.0),
      body: Expanded(
        child: _filteredData.isEmpty
          ? const Text('No data available')
          : ListView.builder(
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final item = _filteredData[index];
                return ListTile(
                  title: Text(item['stop_name'] ?? 'Unnamed Stop'),
                  subtitle: Text(item['stop_id'] ?? 'No ID'),
                  onTap: () {
                    _showAlert('Vous avez séléctionné ${item['stop_name']}', item['stop_name']);
                  },
                );
              },
            ),
      ),
    );
  }
}
