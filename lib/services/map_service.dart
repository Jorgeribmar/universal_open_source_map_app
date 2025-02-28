import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';

class MapService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'UniversalOpenSourceMapApp/1.0',
    'Accept': 'application/json',
  };

  /// Search for locations by query text
  Future<List<Location>> searchLocations(String query, {int limit = 10}) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': limit.toString(),
          'addressdetails': '1',
        },
      );
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Location.fromOsmSearch(item)).toList();
      } else {
        throw Exception('Failed to search locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching locations: $e');
    }
  }

  /// Get location details by place_id or coordinates
  Future<Location> getLocationDetails({
    String? placeId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // If coordinates are provided, use reverse geocoding instead
      if (latitude != null && longitude != null) {
        return reverseGeocode(latitude, longitude);
      }

      // Otherwise use place_id lookup
      if (placeId == null) {
        throw Exception('Either placeId or coordinates must be provided');
      }

      final Uri uri = Uri.parse(
        '$_baseUrl/details',
      ).replace(queryParameters: {'place_id': placeId, 'format': 'json'});

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Location.fromOsmSearch(data);
      } else {
        throw Exception(
          'Failed to get location details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting location details: $e');
    }
  }

  /// Reverse geocode from coordinates to address
  Future<Location> reverseGeocode(double latitude, double longitude) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/reverse').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Location.fromOsmReverse(data);
      } else {
        throw Exception('Failed to reverse geocode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error reverse geocoding: $e');
    }
  }

  /// Get nearby points of interest
  Future<List<Location>> getNearbyPlaces(
    double latitude,
    double longitude, {
    String type = '',
    double radius = 1000,
  }) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'format': 'json',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'radius': radius.toString(),
          'addressdetails': '1',
          if (type.isNotEmpty) 'amenity': type,
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Location.fromOsmSearch(item)).toList();
      } else {
        throw Exception('Failed to get nearby places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting nearby places: $e');
    }
  }
}
