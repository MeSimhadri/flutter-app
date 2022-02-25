import 'package:location/location.dart';

import '../common/constants.dart';

class LocationService {
  bool _serviceEnabled = false;

  LocationData? _locationData;
  LocationData? get locationData => _locationData;

  bool _canUseLocation = false;
  bool get canUseLocation => _canUseLocation;
  LocationService() {
    init();
  }

  void init() async {
    try {
      var _permissionGranted = PermissionStatus.denied;
      final location = Location();
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
      _locationData = await location.getLocation();
      if (_serviceEnabled &&
          _locationData != null &&
          (_permissionGranted == PermissionStatus.granted ||
              _permissionGranted == PermissionStatus.grantedLimited)) {
        _canUseLocation = true;
      }
    } catch (e) {
      printLog(e);
    }
  }
}
