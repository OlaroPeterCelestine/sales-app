import 'package:geolocator/geolocator.dart';

import '../models/models.dart';

/// Live GPS for geofenced check-in. Reads the device/browser location and
/// updates each outlet's distance via the haversine distance to its
/// coordinates.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Position? lastPosition;

  /// Requests permission and returns the current position, or null if location
  /// is unavailable / denied.
  Future<Position?> current() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      lastPosition = pos;
      return pos;
    } catch (_) {
      return null;
    }
  }

  /// Recomputes every pending stop's [RouteStop.distanceMeters] from [pos].
  void updateDistances(Position pos) {
    for (final stop in SampleData.route) {
      stop.distanceMeters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        stop.lat,
        stop.lng,
      );
    }
  }
}
