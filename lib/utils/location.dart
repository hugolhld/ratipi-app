import 'package:location/location.dart';

LocationData? currentLocation;
Location location = Location();

void getLocation() async {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  currentLocation = await location.getLocation();
  location.onLocationChanged.listen((LocationData newLocation) {
    currentLocation = newLocation;
    // Appeler setState ou mettre à jour la carte
  });
}
