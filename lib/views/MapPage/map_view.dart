import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  MapboxMap? mapboxMap;
  Location location = Location();
  LocationData? currentLocation;
  bool _isMounted = false;
  CircleAnnotationManager? circleAnnotationManager;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _handleLocationPermissions();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _handleLocationPermissions() async {
    var status = await Permission.locationAlways.request();
    print(status);
    print(status.isGranted);
    // if (status.isGranted == false) {
      _initLocationTracking();
    // } else {
      print("Location permission denied");
      // Optionally, show a dialog or message to the user explaining why the permission is needed
    // }
  }

  void _initLocationTracking() async {
    print("Init location tracking");
    try {
      currentLocation = await location.getLocation();
      print('current ok');
      print(currentLocation);
      
      location.onLocationChanged.listen((LocationData newLocation) {
        if (_isMounted) {
          print('montouned');
          setState(() {
            currentLocation = newLocation;
          });
          if (mapboxMap != null) {
            print('null map');
            // Update the map's camera position without locking it to the user's location
            mapboxMap?.location.updateSettings(
              LocationComponentSettings(
                enabled: true,
                pulsingEnabled: true,
                puckBearingEnabled: true,
              ),
            );
          }
        }
      });
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        puckBearingEnabled: true,
      ),
    );

    mapboxMap.annotations.createCircleAnnotationManager().then((manager) {
      circleAnnotationManager = manager;
      _addCircleAnnotations();
    });
  }

  void _addCircleAnnotations() async {
    if (circleAnnotationManager == null) return;

    // Exemple de plusieurs cercles avec des numéros
    List<CircleAnnotationOptions> circleOptions = [
      CircleAnnotationOptions(
        // geometry: Point(coordinates: Position(2.3522, 48.8566)), // Paris
        // Add Trocadero coordinates
        geometry: Point(coordinates: Position(2.2886, 48.8628)), // Trocadero
        circleColor: Colors.blue.value,
        circleRadius: 10.0, // Taille du cercle
        circleStrokeColor: Colors.white.value, // Bordure blanche
        circleStrokeWidth: 2.0, // Épaisseur de la bordure
      ),
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(2.2945, 48.8584)), // Tour Eiffel
        circleColor: Colors.blue.value,
        circleRadius: 10.0,
        circleStrokeColor: Colors.white.value,
        circleStrokeWidth: 2.0,
      ),
    ];

    await circleAnnotationManager!.createMulti(circleOptions);
  }

  @override
  Widget build(BuildContext context) {

    print(currentLocation);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Live Location with Mapbox'),
      // ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapWidget(
                  key: ValueKey("mapWidget"),
                  cameraOptions: CameraOptions(
                    center: currentLocation != null
                        ? Point(
                            coordinates: Position(
                              currentLocation!.longitude!,
                              currentLocation!.latitude!,
                            ),
                          )
                        : null,
                    zoom: 15.0,
                  ),
                  onMapCreated: _onMapCreated,
                )
              ],
            ),
    );
  }
}
