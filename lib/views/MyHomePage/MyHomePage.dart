import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:explore_fultter/components/ListItem.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredData = [];
  Set<String> _selectedModes = {}; // Store selected modes for filtering

  // Load unique metro or tramway lines (not stations)
  Future<void> _loadData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/arrets-lignes.json');
      final List<dynamic> data = json.decode(response);

      // Extract unique lines based on 'route_long_name' and 'mode'
      final Set<String> seenLines = {}; // Track unique line identifiers
      final List<Map<String, dynamic>> filteredData = data
          .map((item) => item['fields'] as Map<String, dynamic>?)
          .where((fields) =>
              fields != null &&
              (fields['mode'] == 'Metro' ||
                  fields['mode'] == 'Tramway' ||
                  fields['mode'] == 'RapidTransit') &&
              fields['route_long_name'] != null)
          .where((fields) {
            // Create a unique key for each line using 'route_long_name' and 'mode'
            final lineIdentifier =
                '${fields!['route_long_name']}_${fields['mode']}';
            if (seenLines.contains(lineIdentifier)) {
              return false; // Skip if we've seen this line already
            } else {
              seenLines.add(lineIdentifier);
              return true; // Add if it's a unique line
            }
          })
          .cast<Map<String, dynamic>>() // Ensure non-null entries
          .toList();

      setState(() {
        _filteredData = filteredData;
      });
    } catch (e) {
      print('Error loading asset: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // Filter the list based on the search query and selected modes
    final filteredLines = _filteredData
        .where((item) {
          final title = '${item['mode'] == 'Metro' ? 'Métro' : item['mode'] == 'RapidTransit' ? 'RER' : item['mode']} ${item['route_long_name']}';
          final searchLower = _searchQuery.toLowerCase();
          final mode = item['mode'];
          
          // Check if the item matches the search query and is in the selected modes
          final matchesSearch = title.toLowerCase().contains(searchLower) ||
              item['route_long_name']?.toLowerCase().contains(searchLower);
          final matchesMode = _selectedModes.isEmpty || _selectedModes.contains(mode);
          
          return matchesSearch && matchesMode;
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez votre ligne préférée'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher une ligne',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Update search query
                });
              },
            ),
          ),
          // Add filters here
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterButton(
                  label: 'Métro',
                  isSelected: _selectedModes.contains('Metro'),
                  onPressed: () {
                    setState(() {
                      _toggleModeFilter('Metro');
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterButton(
                  label: 'RER',
                  isSelected: _selectedModes.contains('RapidTransit'),
                  onPressed: () {
                    setState(() {
                      _toggleModeFilter('RapidTransit');
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterButton(
                  label: 'Tramway',
                  isSelected: _selectedModes.contains('Tramway'),
                  onPressed: () {
                    setState(() {
                      _toggleModeFilter('Tramway');
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: filteredLines
                  .map((item) => ListItem(
                        title:
                            '${item['mode'] == 'Metro' ? 'Métro' : item['mode'] == 'RapidTransit' ? 'RER' : item['mode']} ${item['route_long_name']}',
                        subtitle: item['route_long_name'],
                        mode: item['mode'],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Toggle the mode filter
  void _toggleModeFilter(String mode) {
    setState(() {
      if (_selectedModes.contains(mode)) {
        _selectedModes.remove(mode);
      } else {
        _selectedModes.add(mode);
      }
    });
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    super.key, 
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: isSelected ? Colors.teal[400] : Colors.grey[400],
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
