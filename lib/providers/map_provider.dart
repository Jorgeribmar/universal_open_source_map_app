import 'package:flutter/material.dart';
import 'package:universal_open_source_map_app/models/location.dart';
import 'package:universal_open_source_map_app/services/location_service.dart';
import 'package:universal_open_source_map_app/services/map_service.dart';

class MapProvider with ChangeNotifier {
final MapService _mapService;
final LocationService _locationService;

// Current user location
Location? _currentLocation;
Location? get currentLocation => _currentLocation;

// Selected location on map
Location? _selectedLocation;
Location? get selectedLocation => _selectedLocation;

// Search results
List<Location> _searchResults = [];
List<Location> get searchResults => _searchResults;

// Loading states
bool _isLoading = false;
bool get isLoading => _isLoading;

bool _isSearching = false;
bool get isSearching => _isSearching;

String? _error;
String? get error => _error;

MapProvider({
    required MapService mapService,
    required LocationService locationService,
})  : _mapService = mapService,
        _locationService = locationService;

// Get the user's current location
Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
    final position = await _locationService.getCurrentPosition();
    _currentLocation = Location(
        latitude: position.latitude,
        longitude: position.longitude,
        name: 'Current Location',
        address: 'Your current location',
    );
    } catch (e) {
    _error = 'Failed to get current location: $e';
    } finally {
    _isLoading = false;
    notifyListeners();
    }
}

// Search for locations by query
Future<void> searchLocations(String query) async {
    if (query.isEmpty) {
    _searchResults = [];
    notifyListeners();
    return;
    }

    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
    _searchResults = await _mapService.searchLocations(query);
    } catch (e) {
    _error = 'Failed to search locations: $e';
    _searchResults = [];
    } finally {
    _isSearching = false;
    notifyListeners();
    }
}

// Select a location on the map
void selectLocation(Location location) {
    _selectedLocation = location;
    notifyListeners();
}

// Clear the selected location
void clearSelectedLocation() {
    _selectedLocation = null;
    notifyListeners();
}

// Clear search results
void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
}

// Get details for a specific location
Future<Location?> getLocationDetails(Location location) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
    final detailedLocation = await _mapService.getLocationDetails(
        latitude: location.latitude,
        longitude: location.longitude
    );
    
    if (detailedLocation != null) {
        // Update selected location with detailed information
        _selectedLocation = detailedLocation;
    }
    
    return detailedLocation;
    } catch (e) {
    _error = 'Failed to get location details: $e';
    return null;
    } finally {
    _isLoading = false;
    notifyListeners();
    }
}
}

