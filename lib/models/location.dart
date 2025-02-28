class Location {
final double latitude;
final double longitude;
final String name;
final String address;

// Optional properties for additional data from OSM
final String? placeId;
final Map<String, dynamic>? addressComponents;

Location({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.address,
    this.placeId,
    this.addressComponents,
});

factory Location.fromJson(Map<String, dynamic> json) {
return Location(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    name: json['name'] as String,
    address: json['address'] as String,
    placeId: json['placeId'] as String?,
    addressComponents: json['addressComponents'] as Map<String, dynamic>?,
);
}

// Parse OpenStreetMap search API response
factory Location.fromOsmSearch(Map<String, dynamic> json) {
// Extract coordinates and convert to double
final double lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
final double lon = double.tryParse(json['lon']?.toString() ?? '') ?? 0.0;

// Determine the name from display_name or name fields
final String displayName = json['display_name'] ?? '';
final String name = json['name'] ?? displayName.split(',').first;

return Location(
    latitude: lat,
    longitude: lon,
    name: name,
    address: displayName,
    placeId: json['place_id']?.toString(),
    addressComponents: json,
);
}

// Parse OpenStreetMap reverse geocoding API response
factory Location.fromOsmReverse(Map<String, dynamic> json) {
// Extract coordinates
final double lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
final double lon = double.tryParse(json['lon']?.toString() ?? '') ?? 0.0;

// For reverse geocoding, we need to handle the address object
final String displayName = json['display_name'] ?? '';
String name = '';

// Try to get name from address components
if (json.containsKey('address')) {
    final address = json['address'] as Map<String, dynamic>;
    name = address['amenity'] ?? 
        address['building'] ?? 
        address['shop'] ?? 
        address['tourism'] ?? 
        address['leisure'] ?? 
        address['road'] ?? 
        displayName.split(',').first;
} else {
    name = displayName.split(',').first;
}

return Location(
    latitude: lat,
    longitude: lon,
    name: name,
    address: displayName,
    placeId: json['place_id']?.toString(),
    addressComponents: json.containsKey('address') ? json['address'] as Map<String, dynamic> : null,
);
}

Map<String, dynamic> toJson() {
    return {
    'latitude': latitude,
    'longitude': longitude,
    'name': name,
    'address': address,
    if (placeId != null) 'placeId': placeId,
    if (addressComponents != null) 'addressComponents': addressComponents,
    };
}
}

