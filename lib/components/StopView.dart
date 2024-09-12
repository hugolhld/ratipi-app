import 'dart:convert';
import 'package:explore_fultter/utils/firebase.dart';
import 'package:explore_fultter/utils/web_socket_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StopView extends StatefulWidget {
  final String stopTitle;
  final String mode;

  const StopView({
    required this.stopTitle,
    required this.mode,
    super.key,
  });

  @override
  _StopViewState createState() => _StopViewState();
}

class _StopViewState extends State<StopView> {
  Map<String, List<Map<String, dynamic>>> _groupedData = {};

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
          .where((fields) => fields['mode'] == widget.mode && fields['route_long_name'] == widget.stopTitle)
          .toList();

      // Sort the filtered data by stop_name in alphabetical order
      filteredData.sort((a, b) {
        final nameA = a['stop_name']?.toLowerCase() ?? '';
        final nameB = b['stop_name']?.toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      // Group data by route_long_name
      final Map<String, List<Map<String, dynamic>>> groupedData = {};
      for (var item in filteredData) {
        final route = item['route_long_name'] ?? 'Unknown Route';
        if (groupedData[route] == null) {
          groupedData[route] = [];
        }
        groupedData[route]!.add(item);
      }

      setState(() {
        _groupedData = groupedData;
      });

      print(groupedData);
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
        title: Text('Arrêts de la ligne ${widget.stopTitle}'),
      ),
      body: _groupedData.isEmpty
        ? const Center(child: Text('No data available'))
        : ListView.builder(
            itemCount: _groupedData.keys.length,
            itemBuilder: (context, index) {
              final route = _groupedData.keys.elementAt(index);
              final stops = _groupedData[route]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...stops.map((item) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(item['stop_name'] ?? 'Unnamed Stop'),
                          subtitle: Text(item['stop_id'] ?? 'No ID'),
                          onTap: () {
                            _showAlert('Vous avez séléctionné ${item['stop_name']}', item['stop_name']);
                          },
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                        ),
                      ],
                    );
                  }),
                ],
              );
            },
          ),
    );
  }
}
