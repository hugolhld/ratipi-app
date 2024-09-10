import 'dart:convert';
import 'package:explore_fultter/components/ChatView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                    // Uncomment to navigate to ChatView
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatView(title: item['stop_name'] ?? 'Unnamed Stop'),
                      ),
                    );
                  },
                );
              },
            ),
      ),
    );
  }
}
