import 'package:geolocator/geolocator.dart';

class LocationService {
/// Determines if location services are enabled on the device.
Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
}

/// Determines the current permission status.
Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
}

/// Requests permission to access the device's location.
Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
}

/// Retrieves the current position.
/// 
/// Throws a [LocationServiceDisabledException] if location services are disabled.
/// Throws a [PermissionDeniedException] if permission to access location is denied.
/// Throws a [PermissionDeniedForeverException] if permission to access location is permanently denied.
Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
    bool forceAndroidLocationManager = false,
}) async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
    throw LocationServiceDisabledException();
    }

    // Check if we have permission to access location
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
    permission = await requestPermission();
    if (permission == LocationPermission.denied) {
        throw PermissionDeniedException('Location permission denied');
    }
    }

    if (permission == LocationPermission.deniedForever) {
    throw PermissionDeniedException(
        'Location permission permanently denied, we cannot request permissions');
    }

    // We have permission, get the location
    return await Geolocator.getCurrentPosition(
    desiredAccuracy: accuracy,
    timeLimit: timeLimit,
    forceAndroidLocationManager: forceAndroidLocationManager,
    );
}

/// Gets the last known position stored on the device.
/// 
/// Returns `null` if no location is available.
Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
}
}

