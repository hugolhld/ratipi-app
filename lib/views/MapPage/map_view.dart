import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Page')),
      body: const LocationPageBody(),
    );
  }
}

class LocationPageBody extends StatefulWidget {
  const LocationPageBody({super.key});

  @override
  State<StatefulWidget> createState() => LocationPageBodyState();
}

class LocationPageBodyState extends State<LocationPageBody> {
  MapboxMap? _mapboxMap;

  // Handler for when the map is created
  void _onMapCreated(MapboxMap mapboxMap) {
    setState(() {
      _mapboxMap = mapboxMap;
    });

    // Enable location tracking
    _mapboxMap?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    // Get the current location and center the map
    _mapboxMap?.location.getSettings().then((location) {
      if (location != null) {
        // Update the camera position to center on the user's location
        _mapboxMap?.camera.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(location.latitude, location.longitude)),
            zoom: 14.0,
          ),
        );
      } else {
        print("Unable to get the location.");
      }
    }).catchError((error) {
      print("Error getting location: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: MapWidget(
            onMapCreated: _onMapCreated,
          ),
        ),
      ],
    );
  }
}

class MapWidget extends StatelessWidget {
  final void Function(MapboxMap) onMapCreated;

  const MapWidget({super.key, required this.onMapCreated});

  @override
  Widget build(BuildContext context) {
    // return Stack(
    //   children: [
        ...MapboxMap(
      // accessToken: 'YOUR_ACCESS_TOKEN_HERE', // Remplace avec ta clé API Mapbox
      // initialCameraPosition: CameraPosition(
      //   target: LatLng(37.7749, -122.4194), // Coordonnées initiales de la caméra
      //   zoom: 5.0,
      // ),
      onMapCreated: onMapCreated, mapboxMapsPlatform: null,
    )
    // ]
    // )
  }
}
